import { z } from 'zod';
import { User } from '../../domain/entities/user';

export const userModelSchema = z.object({
  id: z.string(),
  name: z.string(),
  email: z.string().email(),
  photoUrl: z.string().nullable(),
});

export type UserModelData = z.infer<typeof userModelSchema>;

export class UserModel {
  constructor(
    public readonly id: string,
    public readonly name: string,
    public readonly email: string,
    public readonly photoUrl: string | null,
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
    id: string | null;
    name: string | null;
    email: string;
    photo: string | null;
  }): UserModel {
    return new UserModel(
      userInfo.id ?? userInfo.email,
      userInfo.name ?? '',
      userInfo.email,
      userInfo.photo ?? null,
    );
  }
}
