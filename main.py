from fastapi import FastAPI, Request

app = FastAPI()

@app.get("/")
async def root():
    return {"message": "Hello World!"}

@app.post("/names")
async def create_name(req: Request):
    return await req.json()

#sample comment for testing
