import { z } from 'zod';

import { User } from '@/src/features/authentication/domain/entities/user';

export const userModelSchema = z.object({
  id: z.string().min(1),
  name: z.string().min(1),
  email: z.email(),
  photoUrl: z.string().url().nullable(),
});

export type UserModelData = z.infer<typeof userModelSchema>;

export class UserModel {
  constructor(
    public readonly id: string,
    public readonly name: string,
    public readonly email: string,
    public readonly photoUrl: string | null,
  ) {}

  static fromJson(json: unknown): UserModel {
    const parsed = userModelSchema.parse(json);
    return new UserModel(parsed.id, parsed.name, parsed.email, parsed.photoUrl);
  }

  static fromGoogleUser(userInfo: Record<string, unknown>): UserModel {
    const user = (
      typeof userInfo.user === 'object' && userInfo.user
        ? userInfo.user
        : userInfo
    ) as Record<string, unknown>;

    return UserModel.fromJson({
      id: typeof user.id === 'string' ? user.id : '',
      name: typeof user.name === 'string' ? user.name : '',
      email: typeof user.email === 'string' ? user.email : '',
      photoUrl: typeof user.photo === 'string' ? user.photo : null,
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
