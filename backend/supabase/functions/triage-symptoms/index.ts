import { GoogleGenerativeAI } from "https://esm.sh/@google/generative-ai"
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders })

  try {
    const { symptoms } = await req.json()

    // API Key Check
    const apiKey = Deno.env.get('GEMINI_API_KEY')
    if (!apiKey) throw new Error('GEMINI_API_KEY not set')

    const genAI = new GoogleGenerativeAI(apiKey)
    const model = genAI.getGenerativeModel({ model: "gemini-2.5-flash" })

    // 🤖 DOCTOR BRAIN PROMPT
    // আমরা AI কে বলছি স্পেশালিস্টের নামগুলো যেন স্ট্যান্ডার্ড হয়, যাতে পরে ডাটাবেসে সার্চ করা যায়।
    const prompt = `
    Role: Professional Medical Triage Nurse.
    Input Symptoms: "${symptoms}"

    Task: Analyze the symptoms and suggest the correct specialist.

    Output Format: JSON ONLY (No markdown, no extra text).
    {
      "condition": "Brief possible condition (e.g., Migraine)",
      "specialty": "Standard Medical Specialty (e.g., NEUROLOGIST, CARDIOLOGIST, DENTIST, GENERAL_PHYSICIAN)",
      "urgency": "HIGH/MEDIUM/LOW",
      "advice": "One line immediate advice (e.g., Rest in a dark room)",
      "reasoning": "Why this specialty?"
    }
    `

    const result = await model.generateContent(prompt)
    const text = result.response.text()

    // Clean JSON (Markdown remove)
    const cleanedText = text.replace(/```json/g, '').replace(/```/g, '').trim()

    return new Response(cleanedText, {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200,
    })

  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 400,
    })
  }
})