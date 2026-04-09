export function isPalindrome(input: string): boolean {
  const cleaned = input.replace(/[^a-zA-Z0-9]/g, '').toLowerCase();
  return cleaned === cleaned.split('').reverse().join('');
}

export function countWords(input: string): number {
  const trimmed = input.trim();
  if (trimmed === '') return 0;
  return trimmed.split(/\s+/).length;
}

export function reverseWords(input: string): string {
  return input.split(/\s+/).reverse().join(' ');
}

export function capitalizeWords(input: string): string {
  return input.replace(/\b\w/g, (char) => char.toUpperCase());
}

export function removeVowels(input: string): string {
  return input.replace(/[aeiouAEIOU]/g, '');
}

export function isValidEmail(email: string): boolean {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}
