# App on the phone

Open the website on the phone and install it: Safari → Share → "Add to Home Screen", or Chrome → menu → "Install app". It opens full-screen, works offline with every recipe saved, and when online always shows the latest version, so new recipes appear right after a deploy without reinstalling.

## Testing it locally

The offline part needs a web server, so it doesn't work when opening the files from disk. Build the website, then run `python3 -m http.server -d build/site 8000` and open <http://localhost:8000>.

## Testing it on a phone

The phone needs an HTTPS address. With the local server running, run `cloudflared tunnel --url http://localhost:8000` (`brew install cloudflared`, no account needed) and open the printed `https://….trycloudflare.com` address on the phone. If it isn't printed, `curl -s http://127.0.0.1:20241/quicktunnel` shows it. Delete the test app from the phone afterwards; the address stops working when the tunnel stops.

## Icons

After changing the icon (`assets/favicon.svg` or `tool/icon-maskable.svg`), re-render the app icons with `sh tool/render_icons.sh` (macOS with Chrome).
