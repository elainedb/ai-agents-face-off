import { z } from 'zod';
import type { User } from '../../domain/entities/user';

export const userModelSchema = z.object({
  id: z.string(),
  name: z.string(),
  email: z.string().email(),
  photoUrl: z.string().nullable(),
});

export type UserModelData = z.infer<typeof userModelSchema>;

export class UserModel {
  constructor(
    readonly id: string,
    readonly name: string,
    readonly email: string,
    readonly photoUrl: string | null,
  ) {}

  toEntity(): User {
    return {
      id: this.id,
      name: this.name,
      email: this.email,
      photoUrl: this.photoUrl,
    };
  }

  static fromGoogleUser(userInfo: {
    id?: string | null;
    name?: string | null;
    email?: string | null;
    photo?: string | null;
  }): UserModel {
    const validated = userModelSchema.parse({
      id: userInfo.id ?? '',
      name: userInfo.name ?? '',
      email: userInfo.email ?? '',
      photoUrl: userInfo.photo ?? null,
    });
    return new UserModel(validated.id, validated.name, validated.email, validated.photoUrl);
  }
}
