from flask import Flask, render_template_string

app = Flask(__name__)

@app.route('/')
def home():
    return render_template_string("""
        <html>
            <head>
                <title>Flask App on Kubernetes</title>
                <style>
                    body {
                        text-align: center;
                        font-family: Arial, sans-serif;
                        margin-top: 40px;
                    }
                    .logo {
                        width: 25%;
                    }
                    .thankyou-text {
                        font-weight: bold;
                        font-size: 20px;
                        margin-top: 30px;
                    }
                </style>
            </head>
            <body>
                <img src="/static/softility.png" alt="Softility Logo" class="logo"><br><br>
                <h2>Hello everyone, Flask App running on Kubernetes!</h2>
                <p>Demo by Viswanadh Chejarla</p>
                <div class="thankyou-text">Thank You</div>
            </body>
        </html>
    """)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
