require 'sinatra'
require 'sqlite3'
require 'slim'
require 'sinatra/reloader'
require 'bcrypt'

post('/user') do
    user = params[:user]
    password = params[:password]
    password_confirm = params[:password_confirm]

    db = SQLite3::Database.new("db/store.db")
    result = db.execute("SELECT id FROM users WHERE user =?", user)
    if result.empty?
        if password == password_confirm
            password_digest = BCrypt::Password.create(password)
            db.execute("INSERT INTO users (user, password_digest) VALUES (?, ?)", [user, password_digest])
            redirect('/welcome')
        else
            redirect('/error') #Lösenord matchar inte
        end
    else
        redirect('/login')
    end
end

enable :session
post('/login') do
    user = params[:user]
    password = params[:password]

    db = SQLite3::Database.new("db/store.db")
    db.results_as_hash = true
    result = db.execute("SELECT id, password_digest FROM users WHERE user =?", user)
    if !result.empty?
        redirect('/error') #Fel lösenord/username
    end
    user_id = result.first("id")
    password_digest = result.first("password_digest")
    if BCrypt::Password.new(password_digest) == password
        session[:user_id] = user_id
        redirect('/welcome')
    else
        redirect('/error') #Fel lösenord/username
    end
end

post('/todos/:id/done') do
    id = params[:id].to_i
    db = SQLite3::Database.new("db/todos.db")
    db.execute("UPDATE todos SET state = 1 WHERE id = ?", id)
    redirect('/todos')
    end

post('/todos/:id/undone') do
    id = params[:id].to_i
    db = SQLite3::Database.new("db/todos.db")
    db.execute("UPDATE todos SET state = 0 WHERE id = ?", id)
    redirect('/todos')
    end

post ('/todos/:id/delete') do
    #hämta todos
        id = params[:id].to_i
    #koppla till databasen
        db = SQLite3::Database.new("db/todos.db")
        db.execute("DELETE FROM todos WHERE id = ?", id)
        redirect('/todos')
    end
    
post ('/todos/:id/update') do
        #plocka upp id, name och description
        id = params[:id].to_i
        name = params[:name]
        description = params[:description]
        #koppla till databasen
        db = SQLite3::Database.new("db/todos.db")
        db.execute("UPDATE todos SET name = ?, description = ? WHERE id = ?",[name,description,id])
        #slutligen, redirect till todos
        redirect('/todos')
    end

get ('/todos') do
        query = params[:q]
    #gör en koppling till databasen
    db = SQLite3::Database.new("db/todos.db")
    edit_id = params[:edit_id]
    
    #[{}, {}, {}] vill vi ha, inte [[], []]
    db.results_as_hash = true
    
    #hämta allt från databasen
    @datatodo = db.execute("SELECT * FROM todos")
    
    p @datatodo
    
    if query && !query.empty?
        @datatodo = db.execute("SELECT * FROM todos WHERE name LIKE ?", "%#{query}%")
    else
        @datatodo = db.execute("SELECT * FROM todos")
    end
    
    #visa upp med slim
    slim(:"todos/index")
    end
    
post ('/todos') do
        new_todo = params[:new_todo]
        description = params[:description]
        category = params[:category] || "privat"
        db = SQLite3::Database.new("db/todos.db")
        db.execute("INSERT INTO todos (name, description, category) VALUES (?,?,?)",[new_todo,description,category])
        redirect('/todos') # Hoppa till routen som visar upp alla todos
    end