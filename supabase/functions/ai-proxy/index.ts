// ECOTRACK NAMIBIA — SUPABASE EDGE FUNCTION
// File: ai-proxy/index.ts
// Purpose: Authenticated OpenAI Chat Completions proxy with rate limiting
// Date: 2026-05-17
// Language: TypeScript/Deno

// @ts-ignore — Deno runtime provides these globals
import { serve } from "https://deno.land/std@0.208.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

// ============================================================================
// CONSTANTS & TYPES
// ============================================================================

const SUPABASE_URL = Deno.env.get("SUPABASE_URL") || "";
const SUPABASE_ANON_KEY = Deno.env.get("SUPABASE_ANON_KEY") || "";
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") || "";
const OPENAI_API_KEY = Deno.env.get("OPENAI_API_KEY") || "";

// Rate limit: max calls per user per hour
const RATE_LIMIT_PER_HOUR = 10;

interface AIProxyRequest {
  prompt?: string;
  model?: string;
}

interface AIProxyResponse {
  result?: string;
  error?: string;
  retryAfter?: number;
}

// ============================================================================
// CORS HEADERS
// ============================================================================
// Applied to every response for browser compatibility.
// Allows requests from any origin (CORS is not a security boundary).

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

// ============================================================================
// ERROR RESPONSE HELPERS
// ============================================================================

function errorResponse(statusCode: number, message: string, retryAfter?: number): Response {
  const body: AIProxyResponse = { error: message };
  if (retryAfter) body.retryAfter = retryAfter;

  return new Response(JSON.stringify(body), {
    status: statusCode,
    headers: {
      "Content-Type": "application/json",
      ...corsHeaders,
    },
  });
}

function successResponse(result: string): Response {
  const body: AIProxyResponse = { result };

  return new Response(JSON.stringify(body), {
    status: 200,
    headers: {
      "Content-Type": "application/json",
      ...corsHeaders,
    },
  });
}

// ============================================================================
// MAIN REQUEST HANDLER
// ============================================================================

serve(async (req: Request) => {
  // STEP 1: Handle OPTIONS preflight with CORS headers and return 200 immediately.
  // Browser sends OPTIONS before cross-origin POST to check if server allows it.
  if (req.method === "OPTIONS") {
    return new Response("ok", {
      status: 200,
      headers: corsHeaders,
    });
  }

  // STEP 2: Reject any method that is not POST with 405.
  if (req.method !== "POST") {
    return errorResponse(405, "Method Not Allowed");
  }

  try {
    // STEP 3: Extract the Bearer token from the Authorization header.
    // Format: "Bearer <token>"
    // If missing or malformed: return 401.
    const authHeader = req.headers.get("Authorization");
    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      return errorResponse(401, "Unauthorised");
    }

    const token = authHeader.slice(7); // Remove "Bearer " prefix

    // STEP 4: Verify the token using Supabase client.
    // The anon key client verifies the JWT signature without making a DB query.
    // If the token is invalid, expired, or tampered: getUser() returns an error.
    const anonSupabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
      global: {
        headers: {
          Authorization: `Bearer ${token}`,
        },
      },
    });

    const { data: { user }, error: authError } = await anonSupabase.auth.getUser(token);

    // If token is invalid or user is null: return 401.
    // This catches: expired tokens, tampered signatures, non-existent users.
    if (authError || !user) {
      return errorResponse(401, "Invalid or expired token");
    }

    // STEP 5: Rate limit check.
    // Use service role client to query ai_usage_log.
    // Service role bypasses RLS, so we can count all calls (not just the user's visible rows).
    const serviceSupabase = createClient(SUPABASE_URL, SUPABASE_URL, {
      global: {
        headers: {
          Authorization: `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
        },
      },
    });

    // Count calls in the last hour
    const { data: callData, error: countError } = await serviceSupabase
      .from("ai_usage_log")
      .select("called_at")
      .eq("user_id", user.id)
      .gte("called_at", new Date(Date.now() - 3600000).toISOString());

    if (countError) {
      return errorResponse(500, "Database error");
    }

    // If rate limit exceeded: return 429 with retryAfter.
    // retryAfter = seconds until oldest call expires from the 1-hour window.
    if (callData && callData.length >= RATE_LIMIT_PER_HOUR) {
      const oldestCall = new Date(callData[0].called_at).getTime();
      const expiresAt = oldestCall + 3600000;
      const retryAfterSeconds = Math.ceil((expiresAt - Date.now()) / 1000);

      return errorResponse(429, "Rate limit exceeded", retryAfterSeconds);
    }

    // STEP 6: Parse request body.
    // Expect: { "prompt": string, "model"?: string }
    // If prompt is missing or not a string: return 400.
    let body: AIProxyRequest;
    try {
      body = await req.json();
    } catch {
      return errorResponse(400, "Invalid JSON");
    }

    if (!body.prompt || typeof body.prompt !== "string") {
      return errorResponse(400, "prompt is required");
    }

    const model = body.model || "gpt-4o-mini"; // Default to gpt-4o-mini
    const userPrompt = body.prompt.trim();

    if (userPrompt.length === 0) {
      return errorResponse(400, "prompt cannot be empty");
    }

    // STEP 7: Call OpenAI Chat Completions API.
    // Key is read from environment variable, never from request or headers.
    // On OpenAI error: return 502 (Bad Gateway) — do NOT forward raw error details.
    let openaiResponse: Response;
    try {
      openaiResponse = await fetch("https://api.openai.com/v1/chat/completions", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${OPENAI_API_KEY}`,
        },
        body: JSON.stringify({
          model,
          messages: [
            {
              role: "user",
              content: userPrompt,
            },
          ],
          temperature: 0.7,
          max_tokens: 1000,
        }),
      });
    } catch (e) {
      console.error("OpenAI request failed:", e);
      return errorResponse(502, "AI service unavailable");
    }

    // Parse OpenAI response.
    if (!openaiResponse.ok) {
      console.error("OpenAI error status:", openaiResponse.status);
      // Do NOT forward the raw OpenAI error to client — that could leak internal details.
      return errorResponse(502, "AI service unavailable");
    }

    const openaiData = await openaiResponse.json();

    // Validate response structure
    if (!openaiData.choices || !openaiData.choices[0] || !openaiData.choices[0].message) {
      console.error("Unexpected OpenAI response structure:", openaiData);
      return errorResponse(502, "AI service unavailable");
    }

    const assistantMessage = openaiData.choices[0].message.content;
    const promptTokens = openaiData.usage?.prompt_tokens || 0;
    const completionTokens = openaiData.usage?.completion_tokens || 0;
    const totalTokens = openaiData.usage?.total_tokens || 0;

    // STEP 8: Log the AI call to ai_usage_log using service role.
    // Service role bypasses RLS, allowing the insertion even though the anon client cannot.
    // This ensures the log is immutable and complete — users cannot forge entries.
    const { error: logError } = await serviceSupabase
      .from("ai_usage_log")
      .insert({
        user_id: user.id,
        prompt_tokens: promptTokens,
        completion_tokens: completionTokens,
        total_tokens: totalTokens,
        model,
        called_at: new Date().toISOString(),
      });

    if (logError) {
      console.error("Failed to log AI usage:", logError);
      // Log error is not critical — AI call succeeded, but audit failed.
      // Still return the result to user; log failure is observed via monitoring.
    }

    // STEP 9: Return 200 with the assistant message.
    return successResponse(assistantMessage);

  } catch (e) {
    console.error("Unhandled exception:", e);
    // Never let exceptions leak to client — always return structured JSON error.
    return errorResponse(500, "Internal server error");
  }
});

// ============================================================================
// SECURITY COMMENTARY
// ============================================================================
/*
WHY SERVICE ROLE IS USED FOR INSERTS:
- The anon key has RLS policies that DENY all INSERTs to ai_usage_log.
- The Edge Function has access to SUPABASE_SERVICE_ROLE_KEY, which bypasses RLS.
- This ensures only the server (never the client) can log AI calls.
- User cannot forge a fake call log to bypass rate limiting.

WHY THE OPENAI KEY IS NEVER READ FROM REQUEST:
- The key comes exclusively from Deno.env.get("OPENAI_API_KEY").
- If the client could pass the key, they would call OpenAI directly, bypassing rate limits.
- The Edge Function acts as a proxy specifically to enforce server-side rate limiting.
- The key is set via `supabase secrets set OPENAI_API_KEY=...` — never in code or .env.

WHY RAW OPENAI ERRORS ARE SUPPRESSED:
- OpenAI errors may contain: API error details, account info, quota info, internal IDs.
- Leaking these details is an information disclosure vulnerability.
- The client cannot take action on a specific OpenAI error anyway.
- We log the raw error server-side for debugging, but return a generic 502 to client.

RATE LIMIT ENFORCEMENT:
- Checked server-side only — client cannot bypass by modifying the response.
- Uses ai_usage_log table with server-role inserts — client cannot forge logs.
- Per-user, per-hour limit prevents abuse while allowing legitimate usage.
*/

// ============================================================================
// DEPLOYMENT STEPS
// ============================================================================
/*
1. Save this file as supabase/functions/ai-proxy/index.ts

2. Deploy the function:
   supabase functions deploy ai-proxy

3. Set the OpenAI API key secret:
   supabase secrets set OPENAI_API_KEY=sk-proj-...

4. Test via curl:
   curl -X POST https://<project>.supabase.co/functions/v1/ai-proxy \
     -H "Authorization: Bearer <anon_key>" \
     -H "Content-Type: application/json" \
     -d '{"prompt": "Hello, world!"}'

5. Verify ai_usage_log is populated:
   SELECT COUNT(*) FROM ai_usage_log;
*/
