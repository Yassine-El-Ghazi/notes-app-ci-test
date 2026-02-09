
# File: Dockerfile
# Recipe to create a Docker image for our Node.js Notes app

# STEP 1: Use a lightweight Node.js base image
FROM node:18-alpine

# STEP 2: Set working directory inside the container
WORKDIR /app

# STEP 3: Copy dependency files
COPY package*.json ./

# STEP 4: Install only production dependencies
RUN npm install --production

# STEP 5: Copy the rest of the application code
COPY . .

# STEP 6: Expose the port the app runs on
EXPOSE 3000

# STEP 7: Command to start the application
CMD ["node", "app.js"]
