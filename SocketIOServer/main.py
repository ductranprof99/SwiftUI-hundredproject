from flask import Flask, request, session
import json
from flask_socketio import join_room, leave_room, send, SocketIO
import random
from string import ascii_uppercase

app = Flask(__name__)
app.config["SECRET_KEY"] = "hjhjsdahhds"
socketio = SocketIO(app, cors_allowed_origins="*")

rooms = {}

def generate_unique_code(length):
    while True:
        code = ""
        for _ in range(length):
            code += random.choice(ascii_uppercase)
        
        if code not in rooms:
            break
    
    return code
@app.route("/ping", methods=["GET"])
def ping():
    return { "status": "yea" }

@app.route("/room", methods=["POST", "GET"])
def room():
    session.clear()
    if request.method == "POST":
        jsonFormData = dict(request.get_json(force=True))

        name = jsonFormData.get("name")
        code = jsonFormData.get("code")
        join = jsonFormData.get("join", False)
        create = jsonFormData.get("create", False)

        if not name:
            return json.dumps({'success':False, 'error': 1, 'error_message': "Please enter a name."}), 200, {'ContentType':'application/json'}

        if join != False and not code:
            return json.dumps({'success':False, 'error': 2, 'error_message': "Please enter a room code"}), 200, {'ContentType':'application/json'}
        
        room = code
        if create != False:
            room = generate_unique_code(4)
            rooms[room] = {"members": 0, "messages": [], 'member_name': []}
        elif code not in rooms:
            return json.dumps({'success':False, 'error': 3, 'error_message': "Room does not exist."}), 200, {'ContentType':'application/json'}
        elif join and name in rooms[code]["member_name"]:
            return json.dumps({'success':False, 'error': 4, 'error_message': "Username created"}), 200, {'ContentType':'application/json'}
        session["room"] = room
        session["name"] = name
        rooms[room]['member_name'] += [name]
        return json.dumps({'success': True, 'room_code': room, 'error_message': ""}), 200, {'ContentType':'application/json'}
    else:
        jsonFormData = dict(request.get_json(force=True))
        room = jsonFormData.get("room")
        if room is None or jsonFormData.get("name") is None or room not in rooms:
            return json.dumps({'success':False, 'error': 5, 'error_message': "Room not validate"}), 200, {'ContentType':'application/json'}
        return json.dumps({'success': True, 'room_code': room, 'message': rooms[room]["messages"]}), 200, {'ContentType':'application/json'}

@socketio.on("message")
def message(data):
    room = session.get("room")
    if room not in rooms:
        return 
    content = {
        "name": session.get("name"),
        "message": data["data"]
    }
    send(content, to=room)
    rooms[room]["messages"].append(content)
    print(f"{session.get('name')} said: {data['data']}")

@socketio.on("connect")
def connect(auth):
    print(auth)
    room = session.get("room")
    name = session.get("name")
    if not room or not name:
        return
    if room not in rooms:
        leave_room(room)
        return
    
    join_room(room)
    send({"name": name, "message": "has entered the room"}, to=room)
    rooms[room]["members"] += 1
    print(f"{name} joined room {room}")

@socketio.on("disconnect")
def disconnect():
    room = session.get("room")
    name = session.get("name")
    leave_room(room)

    if room in rooms:
        rooms[room]["members"] -= 1
        if rooms[room]["members"] <= 0:
            del rooms[room]
    
    send({"name": name, "message": "has left the room"}, to=room)
    print(f"{name} has left the room {room}")

@socketio.on("typing")
def typing():
    room = session.get("room")
    if room not in rooms:
        return 
    
    content = {
        "name": session.get("name")
    }
    send(content, to=room)
    rooms[room]["typing"].append(content)

@socketio.on("not_typing")
def typing():
    room = session.get("room")
    if room not in rooms:
        return 
    
    content = {
        "name": session.get("name")
    }
    send(content, to=room)
    rooms[room]["not_typing"].append(content)

if __name__ == "__main__":
    socketio.run(app, host= "0.0.0.0", port = 10000,debug=True)