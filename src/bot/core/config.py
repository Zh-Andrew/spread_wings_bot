from dotenv import find_dotenv
from pydantic import AnyUrl, BaseSettings, EmailStr, SecretStr, Field


class CustomDsn(AnyUrl):
    """aiomysqlDSN."""

    allowed_schemes = {"mysql+aiomysql"}


class Settings(BaseSettings):
    """Settings app."""

    db_url: CustomDsn
    telegram_token: SecretStr
    django_token: str = Field(..., env="DJANGO_SECRET_KEY")
    debug: bool = False
    email_host: str
    email_port: int
    email_account: EmailStr
    email_password: str
    default_email_address: str

    redis_host: str
    redis_port: int
    redis: bool = True

    class Config:
        """Env settings."""

        env_file = find_dotenv(".env", raise_error_if_not_found=True)
        env_file_encoding = "utf-8"


settings = Settings()
