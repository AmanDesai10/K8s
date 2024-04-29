FROM dart:stable AS build

WORKDIR /app
COPY pubspec.* ./
RUN dart pub get

COPY . .
RUN dart compile exe bin/b00965752_container_2.dart -o bin/b00965752_container_2

# FROM scratch
# COPY --from=build /runtime/ /
# COPY --from=build /app/bin/b00965752_container_2 /app/bin/

EXPOSE 8080
CMD ["/app/bin/b00965752_container_2"]
