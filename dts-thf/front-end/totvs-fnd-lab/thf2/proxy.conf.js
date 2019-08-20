const PROXY_CONFIG = [
    {
        context: [
            "/totvs-rest",
            "/totvs-login"
        ],
        target: "http://servidorjboss:8280",
        secure: false,
        changeOrigin: true,
        logLevel:"debug",
        autoRewrite: true
    }
]

module.exports = PROXY_CONFIG;

