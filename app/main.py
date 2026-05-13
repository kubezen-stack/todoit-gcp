from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy.orm import Session
from database import SessionLocal, engine
from models import Task, Base

Base.metadata.create_all(bind=engine)
app = FastAPI()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@app.get("/health")
def health():
    return {"status": "ok"}

@app.get("/tasks")
def get_tasks(db: Session = Depends(get_db)):
    return db.query(Task).all()

@app.post("/tasks")
def create_task(title: str, db: Session = Depends(get_db)):
    task = Task(title=title)
    db.add(task)
    db.commit()
    return task

@app.patch("/tasks/{task_id}/done")
def complete_task(task_id: int, db: Session = Depends(get_db)):
    task = db.query(Task).filter(Task.id == task_id).first()
    if not task:
        raise HTTPException(status_code=404, detail="Task not found")
    task.done = True
    db.commit()
    return task