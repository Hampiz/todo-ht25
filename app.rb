require 'sinatra'
require 'sqlite3'
require 'slim'
require 'sinatra/reloader'

post('/todos/:id/done') do
    id = params[:id].to_i
    db = SQLite3::Database.new("db/todos.db")
    db.execute("UPDATE todos SET done = 1 WHERE id = ?", id)
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
        db = SQLite3::Database.new("db/todos.db")
        db.execute("INSERT INTO todos (name, description) VALUES (?,?)",[new_todo,description])
        redirect('/todos') # Hoppa till routen som visar upp alla todos
    end