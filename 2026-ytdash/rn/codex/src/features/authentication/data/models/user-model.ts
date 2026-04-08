import { z } from 'zod';

import type { User } from '@/src/features/authentication/domain/entities/user';

export const userModelSchema = z.object({
  id: z.string().min(1),
  name: z.string().min(1),
  email: z.string().email(),
  photoUrl: z.string().url().nullable(),
});

export class UserModel {
  constructor(
    readonly id: string,
    readonly name: string,
    readonly email: string,
    readonly photoUrl: string | null
  ) {}

  static fromJson(data: unknown): UserModel {
    const parsed = userModelSchema.parse(data);
    return new UserModel(parsed.id, parsed.name, parsed.email, parsed.photoUrl);
  }

  static fromGoogleUser(userInfo: {
    user: {
      id?: string | null;
      name?: string | null;
      email?: string | null;
      photo?: string | null;
    };
  }): UserModel {
    return UserModel.fromJson({
      id: userInfo.user.id ?? userInfo.user.email ?? 'unknown-user',
      name: userInfo.user.name ?? userInfo.user.email ?? 'Unknown User',
      email: userInfo.user.email ?? '',
      photoUrl: userInfo.user.photo ?? null,
    });
  }

  toEntity(): User {
    return {
      id: this.id,
      name: this.name,
      email: this.email,
      photoUrl: this.photoUrl,
    };
  }
}
