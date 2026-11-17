import { createClient } from 'npm:@supabase/supabase-js@2';

const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers':
        'authorization, x-client-info, apikey, content-type, x-supabase-api-version',
};

function json(body: unknown, status = 200) {
    return new Response(JSON.stringify(body), {
        status,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
}

// AI ke jawab mein se JSON nikalta hai (extra lafz ya code fence ho to bhi)
function extractJson(text: string) {
    const start = text.indexOf('{');
    const end = text.lastIndexOf('}');
    if (start === -1 || end <= start) return null;
    try {
        return JSON.parse(text.slice(start, end + 1));
    } catch {
        return null;
    }
}

async function callGroq(prompt: string): Promise<string | null> {
    const key = Deno.env.get('GROQ_API_KEY');
    if (!key) return null;
    const model = Deno.env.get('GROQ_MODEL') ?? 'openai/gpt-oss-20b';
    try {
        const t0 = Date.now();
        const res = await fetch('https://api.groq.com/openai/v1/chat/completions', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                Authorization: `Bearer ${key}`,
            },
            body: JSON.stringify({
                model,
                messages: [{ role: 'user', content: prompt }],
                temperature: 0.2,
            }),
            signal: AbortSignal.timeout(25000),
        });
        console.log('groq ms', Date.now() - t0, 'status', res.status, 'model', model);
        if (!res.ok) {
            console.error('Groq error', res.status, await res.text());
            return null;
        }
        const data = await res.json();
        return data?.choices?.[0]?.message?.content ?? null;
    } catch (e) {
        console.error('Groq failed', String(e));
        return null;
    }
}

async function callGeminiText(prompt: string): Promise<string | null> {
    const key = Deno.env.get('GEMINI_API_KEY');
    if (!key) return null;
    const model = Deno.env.get('GEMINI_MODEL') ?? 'gemini-3.8-flash';
    try {
        const t0 = Date.now();
        const res = await fetch(
            `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent`,
            {
                method: 'POST',
                headers: { 'Content-Type': 'application/json', 'x-goog-api-key': key },
                body: JSON.stringify({
                    contents: [{ parts: [{ text: prompt }] }],
                    generationConfig: { responseMimeType: 'application/json' },
                }),
                signal: AbortSignal.timeout(25000),
            },
        );
        console.log('gemini ms', Date.now() - t0, 'status', res.status, 'model', model);
        if (!res.ok) {
            console.error('Gemini error', res.status, await res.text());
            return null;
        }
        const data = await res.json();
        return data?.candidates?.[0]?.content?.parts?.[0]?.text ?? null;
    } catch (e) {
        console.error('Gemini failed', String(e));
        return null;
    }
}

Deno.serve(async (req) => {
    if (req.method === 'OPTIONS') {
        return new Response('ok', { headers: corsHeaders });
    }

    try {
        const { question, drafts, guide_ids } = await req.json();
        const q = String(question ?? '').trim().slice(0, 1000);
        if (!q) return json({ error: 'question is required' }, 400);

        const draftList = (Array.isArray(drafts) ? drafts : [])
            .slice(0, 100)
            .map((d: { id: unknown; title: unknown }) => ({
                id: String(d.id),
                title: String(d.title),
            }));

        const url = Deno.env.get('SUPABASE_URL');
        const anon = Deno.env.get('SUPABASE_ANON_KEY');
        if (!url || !anon) return json({ error: 'Supabase env is missing' }, 500);

        const supabase = createClient(url, anon, {
            global: { headers: { Authorization: req.headers.get('Authorization') ?? '' } },
        });
        const ids = (Array.isArray(guide_ids) ? guide_ids : [])
            .map(String)
            .slice(0, 5);
        const base = supabase
            .from('legal_guides')
            .select('id, topic, title, summary, steps, documents');
        const { data: rows, error } =
            ids.length > 0 ? await base.in('id', ids) : await base.limit(20);
        if (error) {
            console.error(error);
            return json({ error: 'Could not load guides' }, 500);
        }
        const guides = rows ?? [];

        const guideText = guides.map((g) => ({
            id: g.id,
            topic: g.topic,
            title: g.title,
            summary: g.summary,
            steps: (g.steps ?? []).map(
                (s: { title: string; detail: string }, i: number) =>
                    `${i + 1}. ${s.title}: ${s.detail}`,
            ),
            documents: g.documents ?? [],
        }));

        const prompt =
            `You are a legal information assistant inside a Pakistani legal drafting app.
Answer ONLY using the GUIDES below.

Rules:
- If one or more guides cover the question, explain the process in simple words, step by step, using only what the guides say. Set "grounded" to true and list the ids of the guides you used in "guide_ids".
- If the guides do not cover the question, set "grounded" to false and "guide_ids" to []. Say clearly that the app has no verified information on this. Give at most 2 or 3 sentences of very general orientation WITHOUT naming any specific law, section number, deadline, fee or court. Advise the user to speak to an advocate or a legal aid service. Ask one short clarifying question if it would help.
- Never tell the user what to decide and never predict how a case will end.
- If the question is not about legal matters, politely say you can only help with legal processes and drafts.
- Reply in the same language and script as the user's question (English, Urdu, or Roman Urdu).
- Keep the answer under 180 words.
- If a draft template fits the user's need, put its id in "draft_ids". Use only ids from DRAFTS.

Reply with JSON only and no text outside the JSON, in this shape:
{"answer": "<text>", "grounded": true, "guide_ids": ["<id>"], "draft_ids": ["<id>"]}

GUIDES: ${JSON.stringify(guideText)}
DRAFTS: ${JSON.stringify(draftList)}
USER QUESTION: ${q}`;

        // Pehle Groq (tez), na chale to Gemini
        const out = (await callGroq(prompt)) ?? (await callGeminiText(prompt));
        if (!out) return json({ error: 'AI service unavailable' }, 502);

        const parsed = extractJson(out) as {
            answer?: string;
            grounded?: boolean;
            guide_ids?: string[];
            draft_ids?: string[];
        } | null;
        if (!parsed) {
            return json({
                answer: 'Sorry, I could not prepare an answer. Please try again.',
                grounded: false,
                guides: [],
                draft_ids: [],
            });
        }

        const guideById = new Map(
            guides.map((g) => [String(g.id), String(g.title)]),
        );
        const draftIds = new Set(draftList.map((d: { id: string }) => d.id));

        const usedGuides = (parsed.guide_ids ?? [])
            .map(String)
            .filter((id) => guideById.has(id))
            .slice(0, 3)
            .map((id) => ({ id, title: guideById.get(id) }));
        const usedDrafts = (parsed.draft_ids ?? [])
            .map(String)
            .filter((id) => draftIds.has(id))
            .slice(0, 3);

        return json({
            answer: String(parsed.answer ?? ''),
            grounded: parsed.grounded === true && usedGuides.length > 0,
            guides: usedGuides,
            draft_ids: usedDrafts,
        });
    } catch (e) {
        console.error(e);
        return json({ error: 'Bad request' }, 400);
    }
});