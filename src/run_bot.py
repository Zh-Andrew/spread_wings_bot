import logging.config

from telegram.ext import ApplicationBuilder

from bot.core.config import settings
from bot.handlers.main_handlers import help_handler, start_handler
from src.bot.core.log_config import LOGGING_CONFIG


def main():
    logging.config.dictConfig(LOGGING_CONFIG) 
    logger = logging.getLogger('bot')
    logger.info('start')
    app = ApplicationBuilder().token(settings.telegram_token).build()
    app.add_handlers([start_handler, help_handler])
    app.run_polling()


if __name__ == '__main__':
    main()
