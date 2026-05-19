import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.38.4";

// Types for request and OpenAI response
interface RequestBody {
  prompt: string;
  model?: string;
}

interface OpenAIResponse {
  choices: Array<{
    message: {
      content: string;
    };
  }>;
  usage: {
    prompt_tokens: number;
    completion_tokens: number;
    total_tokens: number;
  };
}

// CORS headers applied to every response
const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

serve(async (req: Request) => {
  // 1. Handle OPTIONS preflight — return 200 with CORS headers immediately
  if (req.method === "OPTIONS") {
    return new Response("OK", { headers: corsHeaders, status: 200 });
  }

  // 2. Reject any method that is not POST with 405
  if (req.method !== "POST") {
    return new Response(
      JSON.stringify({ error: "Method not allowed" }),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 405,
      }
    );
  }

  // 3. Extract the Bearer token from the Authorization header
  const authHeader = req.headers.get("authorization");
  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    return new Response(
      JSON.stringify({ error: "Unauthorised" }),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 401,
      }
    );
  }

  const token = authHeader.slice(7); // Remove "Bearer " prefix

  // Initialize Supabase clients
  const supabaseUrl = Deno.env.get("SUPABASE_URL") || "";
  const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY") || "";
  const supabaseServiceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") || "";

  const supabaseAnon = createClient(supabaseUrl, supabaseAnonKey);
  const supabaseService = createClient(supabaseUrl, supabaseServiceRoleKey);

  // 4. Verify the token using the Supabase client
  const { data: { user }, error } = await supabaseAnon.auth.getUser(token);
  if (error || !user) {
    return new Response(
      JSON.stringify({ error: "Invalid or expired token" }),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 401,
      }
    );
  }

  const userId = user.id;

  // 5. Rate limit check using the service role client
  // SECURITY: Service role is used because RLS policies on ai_usage_log block client
  // queries for rate limiting. Only the Edge Function (with service role) can bypass
  // RLS to enforce platform-level rate limits consistently.
  const oneHourAgo = new Date(Date.now() - 3600000).toISOString();
  const { count: rateLimitCount } = await supabaseService
    .from("ai_usage_log")
    .select("*", { count: "exact", head: true })
    .eq("user_id", userId)
    .gt("called_at", oneHourAgo);

  const recentCallCount = rateLimitCount || 0;
  if (recentCallCount >= 10) {
    const retryAfter = 3600; // seconds
    return new Response(
      JSON.stringify({ error: "Rate limit exceeded", retryAfter }),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 429,
      }
    );
  }

  // 6. Parse request body
  let body: RequestBody;
  try {
    body = await req.json();
  } catch {
    return new Response(
      JSON.stringify({ error: "Invalid JSON" }),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 400,
      }
    );
  }

  const { prompt, model = "gpt-4o-mini" } = body;

  if (!prompt) {
    return new Response(
      JSON.stringify({ error: "prompt is required" }),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 400,
      }
    );
  }

  // 7. Call OpenAI Chat Completions API
  // SECURITY: API key is read from Deno.env only, never from the request.
  // This prevents:
  // - Clients from injecting their own OpenAI keys (privilege escalation)
  // - API key exposure through request logging or error messages
  // - Client from accessing the actual key value via the response
  const openaiApiKey = Deno.env.get("OPENAI_API_KEY");
  if (!openaiApiKey) {
    return new Response(
      JSON.stringify({ error: "AI service unavailable" }),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 502,
      }
    );
  }

  let openaiResponse: OpenAIResponse;
  try {
    const openaiRes = await fetch("https://api.openai.com/v1/chat/completions", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Authorization": `Bearer ${openaiApiKey}`,
      },
      body: JSON.stringify({
        model,
        messages: [{ role: "user", content: prompt }],
      }),
    });

    if (!openaiRes.ok) {
      // SECURITY: Raw OpenAI errors are suppressed to prevent information leakage
      // about rate limits, authentication issues, or internal API structure.
      // Clients only see generic "AI service unavailable".
      console.error(
        `OpenAI API error: ${openaiRes.status} ${openaiRes.statusText}`
      );
      return new Response(
        JSON.stringify({ error: "AI service unavailable" }),
        {
          headers: { ...corsHeaders, "Content-Type": "application/json" },
          status: 502,
        }
      );
    }

    openaiResponse = await openaiRes.json();
  } catch (err) {
    // SECURITY: Catch-all error suppression prevents leaking stack traces or
    // system details (DNS failures, connection timeouts, etc.) to clients.
    console.error("OpenAI request failed:", err);
    return new Response(
      JSON.stringify({ error: "AI service unavailable" }),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 502,
      }
    );
  }

  // Validate OpenAI response structure
  const assistantMessage = openaiResponse.choices?.[0]?.message?.content;
  if (!assistantMessage) {
    return new Response(
      JSON.stringify({ error: "AI service unavailable" }),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 502,
      }
    );
  }

  const { prompt_tokens, completion_tokens, total_tokens } = openaiResponse.usage;

  // 8. Insert into ai_usage_log using the service role client
  // SECURITY: Service role is used because:
  // - Client RLS policies block INSERT on ai_usage_log (by design, see schema)
  // - Only this Edge Function should log AI calls (prevents fake logging)
  // - Service role bypasses RLS to ensure usage is recorded for billing/audit
  const { error: insertError } = await supabaseService
    .from("ai_usage_log")
    .insert({
      user_id: userId,
      prompt_tokens,
      completion_tokens,
      total_tokens,
      model,
      called_at: new Date().toISOString(),
    });

  if (insertError) {
    // Log but don't fail the request — user still gets their response
    console.error("Failed to log AI usage:", insertError);
  }

  // 9. Return 200 { "result": "<assistant message text>" }
  return new Response(
    JSON.stringify({ result: assistantMessage }),
    {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 200,
    }
  );
});

5. Verify ai_usage_log is populated:
   SELECT COUNT(*) FROM ai_usage_log;
*/
