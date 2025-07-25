# Stage 1: Build the app 
FROM node:18-alpine AS builder

# Set working directory
WORKDIR /app

# Install dependencies needed to build native Node modules
RUN apk add --no-cache python3 make g++

# Copy package files and install dependencies
COPY package*.json ./
RUN npm ci

# Copy remaining source code
COPY . .

# Generate Next.js standalone production build
RUN npm run build

# Stage 2: Create lean production image
FROM node:18-alpine AS runner

# Set environment variables
ENV NODE_ENV=production
ENV PORT=3000

# Create non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Set working directory
WORKDIR /app

# Copy only the necessary production files
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
COPY --from=builder /app/public ./public
COPY --from=builder /app/package.json ./package.json

# Change ownership of files to the non-root user
RUN chown -R appuser:appgroup /app

# Use non-root user
USER appuser

# Expose application port
EXPOSE 3000

# Start the app
CMD ["node", "server.js"]
