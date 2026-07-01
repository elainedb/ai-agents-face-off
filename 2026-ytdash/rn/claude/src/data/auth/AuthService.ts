// Auth abstraction (dependency inversion, constitution §1.2). The whitelist decision lives in the
// domain layer; an AuthService only produces the signed-in identity. The identity source swaps
// (mock account in UI-test-mode vs real Google in production) without touching callers.
export type SignedInUser = { email: string };

export interface AuthService {
  signIn(): Promise<SignedInUser>;
  signOut(): Promise<void>;
}
