# =====================================================
# Stage 1 - builder: build the static site with Node.js + Parcel
# =====================================================
# Pinned Node.js image (small Alpine variant); AS names this stage
FROM node:22-alpine AS builder

# Working directory inside the build container
WORKDIR /app

# Copy only the package files first so the dependency layer is cached
COPY package*.json ./

# Clean, reproducible install of dependencies from package-lock.json
RUN npm ci

# Copy the website source files and the shared stylesheet
COPY src/ ./src/
COPY styles/ ./styles/

# Build all pages into /app/dist
RUN npm run build

# =====================================================
# Stage 2 - runtime: serve the built files with Nginx
# =====================================================
# Pinned small Nginx image; Node.js and node_modules are NOT included
FROM nginx:1.27-alpine

# Copy ONLY the built static files from the builder stage
COPY --from=builder /app/dist /usr/share/nginx/html

# Document the port Nginx listens on
EXPOSE 80

# Run Nginx in the foreground so the container keeps running
CMD ["nginx", "-g", "daemon off;"]
# End of Dockerfile 
