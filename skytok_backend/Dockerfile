ARG ARCH=
FROM ${ARCH}node as test
# Create app directory
WORKDIR /usr/src/app
# Install app dependencies
COPY . .
RUN npm install
EXPOSE 80
CMD [ "npm", "run", "test" ]