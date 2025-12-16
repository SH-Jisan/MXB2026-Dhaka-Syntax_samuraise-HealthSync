import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { GoogleAuth } from "google-auth-library"

console.log("🚀 Function started (HTTP v1 Mode)")

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders })

  try {
    // ১. Service Account লোড করা
    const serviceAccountStr = Deno.env.get('FIREBASE_SERVICE_ACCOUNT')
    if (!serviceAccountStr) {
      throw new Error('Missing FIREBASE_SERVICE_ACCOUNT in secrets')
    }
    const serviceAccount = JSON.parse(serviceAccountStr)

    // Private Key ফরম্যাট ফিক্স করা
    const privateKey = serviceAccount.private_key.replace(/\\n/g, '\n')

    // ২. Google Auth ক্লায়েন্ট তৈরি (Access Token পাওয়ার জন্য)
    const auth = new GoogleAuth({
      credentials: {
        client_email: serviceAccount.client_email,
        private_key: privateKey,
        project_id: serviceAccount.project_id,
      },
      scopes: ['https://www.googleapis.com/auth/firebase.messaging'],
    })

    const client = await auth.getClient()
    const accessToken = await client.getAccessToken()

    if (!accessToken.token) {
        throw new Error("Failed to generate Access Token")
    }

    // ৩. রিকোয়েস্ট ডাটা রিসিভ করা
    const { blood_group, hospital, urgency } = await req.json()

    // ৪. Supabase থেকে ডোনার খোঁজা
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const supabase = createClient(supabaseUrl, supabaseKey)

    console.log(`🔍 Finding donors for ${blood_group}...`)

    const { data: donors, error } = await supabase
      .from('blood_donors')
      .select(`
        user_id,
        profiles!inner ( fcm_token )
      `)
      .eq('blood_group', blood_group)
      .eq('availability', true)

    if (error) throw error

    // টোকেন ফিল্টার করা
    const tokens = donors
      .map((d: any) => d.profiles?.fcm_token)
      .filter((token: any) => token && typeof token === 'string' && token.length > 10)

    const uniqueTokens = [...new Set(tokens)] as string[]

    if (uniqueTokens.length === 0) {
      return new Response(JSON.stringify({ message: 'No donors found' }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    console.log(`📢 Sending to ${uniqueTokens.length} devices via HTTP v1...`)

    // ৫. নোটিফিকেশন পাঠানো (Parallel Requests)
    // Firebase HTTP v1 API ব্যাচ সাপোর্ট করে না, তাই আমরা প্যারালাল রিকোয়েস্ট পাঠাব
    const sendPromises = uniqueTokens.map(async (token) => {
      const url = `https://fcm.googleapis.com/v1/projects/${serviceAccount.project_id}/messages:send`

      const payload = {
        message: {
          token: token,
          notification: {
            title: `🩸 Urgent: ${blood_group} Blood Needed!`,
            body: `${urgency} Request at ${hospital}. Tap to help!`,
          },
          data: {
            type: 'blood_request',
            click_action: 'FLUTTER_NOTIFICATION_CLICK',
          }
        }
      }

      const res = await fetch(url, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${accessToken.token}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(payload)
      })

      return res.ok
    })

    // সব রিকোয়েস্ট একসাথে পাঠানো
    const results = await Promise.all(sendPromises)
    const successCount = results.filter(r => r === true).length
    const failureCount = results.length - successCount

    console.log(`✅ Sent: ${successCount}, ❌ Failed: ${failureCount}`)

    return new Response(JSON.stringify({
      success: true,
      sent_count: successCount,
      failed_count: failureCount
    }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })

  } catch (error: any) {
    console.error("❌ Critical Error:", error.message)
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 400,
    })
  }
})