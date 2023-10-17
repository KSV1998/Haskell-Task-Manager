# Haskell Task List Manager

Haskell Task List Manager is a command-line task list manager written in Haskell. It allows you to create, manage, and organize your tasks right from your terminal and through an API.
This application can be operated in two modes
1. Interactive Mode - Where you can manage your tasks through a command-line.
2. API Mode - Where you can manage your tasks through an API.

## Features

- **Add Task:** Add new tasks with titles and descriptions.
- **List Tasks:** View all your tasks.
- **Complete Task:** Mark tasks as completed.
- **Remove Task:** Delete tasks from the list.
- **List Todo Tasks:** View all your todo tasks.
- **List Priority Tasks:** View all your priority tasks.

## Getting Started

Follow these steps to get started with the Haskell Task List Manager.

### Prerequisites

- GHC (Glasgow Haskell Compiler)
- Cabal (Haskell build tool)
- Git (Version control system)

### Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/your-username/haskell-task-list-manager.git
   cd haskell-task-list-manager
    ```
2. Build the project:

   ```bash
   cabal build
   ```
3. Run the executable:

   ```bash
    cabal run HaskellTaskManager -- --encryption-key="Encryption Key" --interactive-mode [args] | --api-mode 
    ```
    - `--encryption-key`: The encryption key to use for decrypting the DB Password. This is a required argument.

### Version Control
#### Version control is a crucial aspect of software development. It allows multiple developers to collaborate on a project, track changes, and ensure code stability. Git is a popular version control system.
1. Checkout to a new branch from Master:
    ```
    git checkout -b new-branch-name
    ```
2. Make changes to the project.
3. Commit your changes:
    ```
    git add .
    git commit -m "Commit message"
    ```
4. Push your changes to the remote repository:
    ```
    git push -u origin new-branch-name
    ```
5. Create a Pull Request (PR) to merge your changes to the Master branch.

## Usage

### This application works in two modes: Interactive Mode and API Mode.

### Interactive Mode
```
cabal run HaskellTaskManager -- --encryption-key="Encryption Key" --interactive-mode [args]
```
- `--encryption-key`: The encryption key to use for decrypting the DB Password. This is a required argument.
- args should be one of the following:
    - to add Task `'add' title description priority`
    - to list all Tasks `'list'`
    - to mark a Task as completed `'complete' title`
    - to remove a Task `'remove' title`
    - to list todo Tasks `'todo-list'`
    - to list priority Tasks `'priority-list'`

- Example : `cabal run HaskellTaskManager -- --encryption-key="Encryption Key" --interactive-mode add "Breakfast" "Eat Dosa for Breakfast" 1`

### API Mode
#### An API Server is started on port 8080. You can send requests to the server to manage your tasks in this mode.
```
cabal run HaskellTaskManager -- --encryption-key="Encryption Key" --api-mode
```
- `--encryption-key`: The encryption key to use for decrypting the DB Password. This is a required argument.
- API Endpoints:
    - `GET` `localhost:8080/tasks`: List all tasks.
    - `GET` `localhost:8080/prioritytasks`: To list priority Tasks.
    - `GET` `localhost:8080/todo`: To list todo Tasks.
    - `GET` `localhost:8080/complete`: To mark a task as completed.
    - `GET` `localhost:8080/remove`: To remove a List.
    - `POST` `localhost:8080/add`: To add a Task.

- Example :
    ```
    cabal run HaskellTaskManager -- --encryption-key="Encryption Key" --api-mode
    curl -X GET "localhost:8080/tasks```

## Database
- Database used : Postgresql
- This is a free tier DB hosted for this project. The creds are hardcoded in the project and Password is stored in encrypted format which can be decrypted using the encryption key provided as an argument to the application.

## Contribution/Suggestions
- For Contribution Please folow steps in Version Control Section of this README.
- For Suggestions please open an issue in the repository or Reach out to `saivenkatesh13@gmail.com`

## Features to be added
- All the DB cred can be provided as configs.
