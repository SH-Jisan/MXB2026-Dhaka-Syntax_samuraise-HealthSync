// supabase/functions/analyze-report/index.ts

import { GoogleGenerativeAI } from "https://esm.sh/@google/generative-ai"
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // CORS হ্যান্ডেল করা
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { imageBase64, mimeType } = await req.json()

    // API Key ভেরিফাই করা
    const apiKey = Deno.env.get('GEMINI_API_KEY')
    if (!apiKey) throw new Error('GEMINI_API_KEY not set')

    // AI কনফিগারেশন
    const genAI = new GoogleGenerativeAI(apiKey)

    // 🔥 CHANGE IS HERE: আপনার লিস্ট থেকে 'gemini-2.5-flash' মডেল ব্যবহার করছি
    const model = genAI.getGenerativeModel({ model: "gemini-2.5-flash" })

    const prompt = `Analyze this medical report. Return strictly valid JSON.
    Fields: title, event_type (REPORT/PRESCRIPTION/SURGERY), event_date (YYYY-MM-DD), severity (HIGH/MEDIUM/LOW), summary.
    Do not use Markdown code blocks.`

    // ইমেজ প্রসেসিং
    const result = await model.generateContent([
      prompt,
      {
        inlineData: {
          data: imageBase64,
          mimeType: mimeType || "image/jpeg",
        },
      },
    ])

    const response = await result.response
    const text = response.text()

    console.log("AI Raw Response:", text)

    // ক্লিন করা
    const cleanedText = text.replace(/```json/g, '').replace(/```/g, '').trim()
    const jsonData = JSON.parse(cleanedText)

    return new Response(JSON.stringify(jsonData), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200,
    })

  } catch (error) {
    console.error("Backend Error:", error)
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 400,
    })
  }
})