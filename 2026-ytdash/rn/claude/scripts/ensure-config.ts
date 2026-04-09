import * as fs from 'fs';
import * as path from 'path';

const configDir = path.resolve(__dirname, '../src/config');

const files = [
  {
    target: 'auth-config.ts',
    template: 'auth-config.template.ts',
  },
  {
    target: 'api-config.ts',
    template: 'api-config.template.ts',
  },
];

for (const file of files) {
  const targetPath = path.join(configDir, file.target);
  const templatePath = path.join(configDir, file.template);
  if (!fs.existsSync(targetPath)) {
    console.log(`Creating ${file.target} from template...`);
    fs.copyFileSync(templatePath, targetPath);
  } else {
    console.log(`${file.target} already exists, skipping.`);
  }
}
