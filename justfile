# `just` is a command runner that simplifies the execution of tasks.
# https://github.com/casey/just

# Show the available commands
default:
  just --list

# Run the development server
server:
	poetry run python manage.py migrate
	poetry run python manage.py runserver 8000 --settings=anxiety_chatbot_project.settings-development

create-superuser:
	poetry run python manage.py createsuperuser
