import * as fs from 'fs';
import * as path from 'path';

const configs = [
  {
    target: path.join(__dirname, '..', 'src', 'config', 'auth-config.ts'),
    content: `export const authorizedEmails: string[] = [];\n`,
  },
  {
    target: path.join(__dirname, '..', 'src', 'config', 'api-config.ts'),
    content: `export const youtubeApiKey = 'PLACEHOLDER_API_KEY';\n`,
  },
];

for (const config of configs) {
  if (!fs.existsSync(config.target)) {
    fs.mkdirSync(path.dirname(config.target), { recursive: true });
    fs.writeFileSync(config.target, config.content, 'utf-8');
    console.log(`Created placeholder: ${config.target}`);
  } else {
    console.log(`Already exists: ${config.target}`);
  }
}
