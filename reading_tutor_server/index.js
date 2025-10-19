const express = require('express');
const dotenv = require('dotenv');
const {Server} = require("socket.io");
import { GoogleGenAI } from "@google/genai";

dotenv.config();
const app = express();

const io = new Server(process.env.SOCKET_PORT);

const ai = new GoogleGenAI({apiKey: process.env.GEMINI_API_KEY});

let players = [];

io.on("connection", (socket) => {
  console.log("a user connected:", socket.id);

  socket.on("join_game", (playerId) => {

    if (!(players.find(p => p.userId === playerId))) {
      players.push({socketId: socket.id, userId: playerId});
    }

    let battleRoom;

    if (players.length % 2 === 0) {
      let playerOne = players[(Math.floor(Math.random() * quickPlayPlayers.length))];
      let playerOneIndex = players.indexOf(playerOne);
      players.splice(playerOneIndex, 1);

      let playerTwo = players[(Math.floor(Math.random() * quickPlayPlayers.length))];
      let playerTwoIndex = players.indexOf(playerTwo);
      players.splice(playerTwoIndex, 1);
      
      battleRoom = [playerOne, playerTwo];

      io.to(playerOne.socketId).emit("start_game", {opponentId: playerTwo.userId, roomId: battleRoom});
      io.to(playerTwo.socketId).emit("start_game", {opponentId: playerOne.userId, roomId: battleRoom});
    }    
  });

  
  socket.on("gameplay", (data) => {
    const {roomId, gameplayData} = data;
   

  })

});



app.listen(process.env.PORT, () => {
  console.log("Server running on PORT", process.env.PORT)
})