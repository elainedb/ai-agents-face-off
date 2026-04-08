import fs from 'node:fs';
import path from 'node:path';

const root = process.cwd();

const files = [
  {
    target: path.join(root, 'src/config/auth-config.ts'),
    contents: "export const authorizedEmails: string[] = [];\n",
  },
  {
    target: path.join(root, 'src/config/api-config.ts'),
    contents: "export const youtubeApiKey = 'YOUR_YOUTUBE_API_KEY_HERE';\n",
  },
];

for (const file of files) {
  if (!fs.existsSync(file.target)) {
    fs.mkdirSync(path.dirname(file.target), { recursive: true });
    fs.writeFileSync(file.target, file.contents, 'utf8');
  }
}
