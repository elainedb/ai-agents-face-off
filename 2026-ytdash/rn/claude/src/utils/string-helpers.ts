export function isPalindrome(input: string): boolean {
  const cleaned = input.replace(/[^a-zA-Z0-9]/g, '').toLowerCase();
  return cleaned === cleaned.split('').reverse().join('');
}

export function countWords(input: string): number {
  const trimmed = input.trim();
  if (trimmed.length === 0) return 0;
  return trimmed.split(/\s+/).length;
}

export function reverseWords(input: string): string {
  return input.trim().split(/\s+/).reverse().join(' ');
}

export function capitalizeWords(input: string): string {
  return input
    .split(' ')
    .map((word) => (word.length > 0 ? word[0].toUpperCase() + word.slice(1).toLowerCase() : ''))
    .join(' ');
}

export function removeVowels(input: string): string {
  return input.replace(/[aeiou]/gi, '');
}

export function isValidEmail(email: string): boolean {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}
