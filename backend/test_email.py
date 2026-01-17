"""Test script for email service"""
import resend

# Set API key
resend.api_key = "re_iM1PeVEe_F1wb5AnuJfJnb2XuucgsPER3"

# Send test email
print("Sending test email...")
try:
    result = resend.Emails.send({
        "from": "Vault <onboarding@resend.dev>",
        "to": "admin@trimesha.com",
        "subject": "Test Email from Vault Password Manager",
        "html": """
        <div style="font-family: Arial, sans-serif; padding: 20px; max-width: 600px; margin: 0 auto;">
            <div style="background: linear-gradient(135deg, #7c3aed 0%, #a855f7 100%); padding: 30px; border-radius: 16px 16px 0 0; text-align: center;">
                <h1 style="color: white; margin: 0;">🔐 Vault</h1>
                <p style="color: rgba(255,255,255,0.8); margin: 10px 0 0 0;">Secure Password Manager</p>
            </div>
            <div style="background: white; padding: 30px; border-radius: 0 0 16px 16px; box-shadow: 0 4px 6px rgba(0,0,0,0.1);">
                <h2 style="color: #18181b; margin-top: 0;">🎉 Test Email Successful!</h2>
                <p style="color: #3f3f46; line-height: 1.6;">
                    Congratulations! Your email service is configured correctly and working properly.
                </p>
                <p style="color: #3f3f46; line-height: 1.6;">
                    This email was sent from <strong>Vault Password Manager</strong> using the Resend API.
                </p>
                <hr style="border: 1px solid #e4e4e7; margin: 20px 0;">
                <p style="color: #71717a; font-size: 12px; text-align: center;">
                    If you received this email, your Resend integration is working properly.
                </p>
            </div>
        </div>
        """
    })
    print(f"✅ Email sent successfully!")
    print(f"Email ID: {result}")
except Exception as e:
    print(f"❌ Failed to send email: {e}")
