FROM node

RUN apt update && apt upgrade -y && apt install -y ffmpeg
RUN mkdir nms 
WORKDIR /nms
RUN npm install node-media-server
COPY ./app.js ./app.js
RUN mkdir ./media

CMD ["node", "app.js"]