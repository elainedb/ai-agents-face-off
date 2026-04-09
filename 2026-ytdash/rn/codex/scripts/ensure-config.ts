import fs from 'node:fs';
import path from 'node:path';

const rootDir = path.resolve(__dirname, '..');

const files = [
  {
    target: path.join(rootDir, 'src/config/auth-config.ts'),
    template: "export const authorizedEmails: string[] = [];\n",
  },
  {
    target: path.join(rootDir, 'src/config/api-config.ts'),
    template: "export const youtubeApiKey = 'YOUR_YOUTUBE_API_KEY_HERE';\n",
  },
];

for (const file of files) {
  if (!fs.existsSync(file.target)) {
    fs.mkdirSync(path.dirname(file.target), { recursive: true });
    fs.writeFileSync(file.target, file.template, 'utf8');
  }
}
