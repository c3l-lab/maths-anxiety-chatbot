# `just` is a command runner that simplifies the execution of tasks.
# https://github.com/casey/just

# Load variables from the .env file
set dotenv-load

# Show the available commands
default:
  just --list

# Run the development server
server: migrate create-superuser
	poetry run python manage.py runserver 8000 --settings=anxiety_chatbot_project.settings-development

migrate:
	poetry run python manage.py migrate

create-superuser:
	poetry run python manage.py createsuperuser --no-input || true

clean:
	rm -rf db.sqlite3
