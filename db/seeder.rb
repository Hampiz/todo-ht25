require 'sqlite3'

db = SQLite3::Database.new("#{__dir__}/todos.db")


def seed!(db)
  puts "Using db file: db/todos.db"
  puts "🧹 Dropping old tables..."
  drop_tables(db)
  puts "🧱 Creating tables..."
  create_tables(db)
  puts "🍎 Populating tables..."
  populate_tables(db)
  puts "✅ Done seeding the database!"
end

def drop_tables(db)
  db.execute('DROP TABLE IF EXISTS todos')
end

def create_tables(db)
  db.execute('CREATE TABLE todos (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL, 
              description TEXT,
              state BOOLEAN,
              category TEXT DEFAULT "privat")')
db.execute('CREATE TABLE user (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL, 
              password_digest TEXT NOT NULL)')
end

def populate_tables(db)
  db.execute('INSERT INTO todos (name, description, state, category) VALUES ("Köp mjölk", "3 liter mellanmjölk, eko", false, "shopping")')
  db.execute('INSERT INTO todos (name, description, state, category) VALUES ("Köp julgran", "En rödgran", false, "shopping")')
  db.execute('INSERT INTO todos (name, description, state, category) VALUES ("Pynta gran", "Glöm inte lamporna i granen och tomten", false, "privat")')
end

seed!(db)