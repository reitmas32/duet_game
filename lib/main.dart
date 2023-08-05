import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';
import 'package:flame/input.dart';
// ignore: library_prefixes
import 'dart:async' as ASYNC;

import 'package:first_game/circle_component.dart' as circle;
import 'package:first_game/moving_rectangle.dart' as rectangle;
import 'package:flame/extensions.dart';

void main() {
  runApp(
    GameWidget(
      game: HelloWorldGame(),
    ),
  );
}

class Pos<T> {
  T x;
  T y;

  Pos({required this.x, required this.y});
}

class Line<T> {
  T startX;
  T startY;
  T endX;
  T endY;

  Line({
    required this.startX,
    required this.startY,
    required this.endX,
    required this.endY,
  });
}

class HelloWorldGame extends FlameGame
    with TapDetector, PanDetector, HasQuadTreeCollisionDetection {
  circle.CircleComponent? circleRed;
  circle.CircleComponent? circleBlue;
  double fps = 0;
  TextPaint? textFpsComponent;
  TextPaint? textComponent;

  List<rectangle.RectangleComponent> rectangles = [];
  ASYNC.Timer? rectangleTimer;
  ASYNC.Timer? linesTimer;
  Random random = Random();
  int countPoints = -4;

  double speed = 2;
  double rectangleSpeed = 200;

  List<List<int>> map = [
    [1, 0],
    [0, 1],
    [1, 0],
    [0, 1],
    [1, 0],
    [0, 1],
    [1, 0],
    [0, 1],
  ];

  int index = 0;

  List<Line>? lines;

  @override
  void update(double dt) {
    super.update(dt);
    if (dt != 0.0) {
      fps = (1 / dt);
    }

    // Actualizar el rectángulo
    circleBlue?.update(dt);
    circleRed?.update(dt);

    for (rectangle.RectangleComponent rec in rectangles) {
      rec.y += dt * rectangleSpeed;
    }

    for (rectangle.RectangleComponent rec in rectangles) {
      bool? redCollision = circleRed?.onCheckCollision(rec);
      bool? blueCollision = circleBlue?.onCheckCollision(rec);

      if (redCollision == true || blueCollision == true) {
        paused = true;
        // Esperar 1 segundo antes de reiniciar el nivel
        ASYNC.Timer(const Duration(seconds: 1), () {
          // Reiniciar el nivel
          resetLevel();
        });

        break;
      }
    }
  }

  void resetLevel() {
    // Restablecer el estado del juego a su estado inicial
    // Aquí debes reconfigurar todas las variables, posiciones, etc., a su estado original
    // por ejemplo:
    circleBlue = circle.CircleComponent(
      position: Vector2((size.x / 4) * 1, 500),
      paint: BasicPalette.blue.paint(),
      speed: 2.5,
      angle: pi,
      centerX: size.x / 2,
      centerY: size.y / 4 * 3,
      calcX: sin,
      calcY: cos,
    );

    circleRed = circle.CircleComponent(
      position: Vector2((size.x / 4) * 1, 500),
      paint: BasicPalette.red.paint(),
      speed: 2.5,
      angle: 0,
      centerX: size.x / 2,
      centerY: size.y / 4 * 3,
      calcX: sin,
      calcY: cos,
    );
    stopRectangleTimer();
    rectangles = []; // restablece la velocidad del rectángulo
    countPoints = -4;
    startRectangleTimer();
    paused = false; // reanuda el juego

    // Aquí puedes realizar cualquier otra acción necesaria para reiniciar el nivel
  }

  @override
  void onTapDown(TapDownInfo info) {
    if (info.eventPosition.game.x <= size.x / 2) {
      circleRed?.onRotateLeft = true;
      circleBlue?.onRotateLeft = true;
    } else {
      circleRed?.onRotateRigth = true;
      circleBlue?.onRotateRigth = true;
    }
  }

  @override
  void onTapUp(TapUpInfo info) {
    if (info.eventPosition.game.x <= size.x / 2) {
      circleRed?.onRotateLeft = false;
      circleBlue?.onRotateLeft = false;
    } else {
      circleRed?.onRotateRigth = false;
      circleBlue?.onRotateRigth = false;
    }
  }

  @override
  void onPanStart(DragStartInfo info) {
    if (info.eventPosition.game.x <= size.x / 2) {
      circleRed?.onRotateLeft = true;
      circleBlue?.onRotateLeft = true;
    } else {
      circleRed?.onRotateRigth = true;
      circleBlue?.onRotateRigth = true;
    }
    super.onPanStart(info);
  }

  @override
  void onPanEnd(DragEndInfo info) {
    circleRed?.onRotateLeft = false;
    circleBlue?.onRotateLeft = false;
    circleRed?.onRotateRigth = false;
    circleBlue?.onRotateRigth = false;
    super.onPanEnd(info);
  }

  @override
  void render(Canvas canvas) {
    // BackgroundColor
    super.render(canvas);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Paint()..color = const Color(0xFF1A1918),
    );

    //Rectangles

    for (rectangle.RectangleComponent rec in rectangles) {
      rec.render(canvas);
    }

    const double radius = 75.0;
    final Paint whitePaint = BasicPalette.gray.paint();
    whitePaint.style = PaintingStyle.stroke;
    whitePaint.strokeWidth = 0.5; // Establece el estilo de trazo

    final Offset position = Offset(size.x / 2, size.y / 4 * 3);
    canvas.drawCircle(position, radius, whitePaint);
    circleBlue?.render(canvas);
    circleRed?.render(canvas);

    if (paused) {
      textComponent!
          .render(canvas, 'Game Over', Vector2(size.x / 2 - 150, size.y / 2));
    }

    textFpsComponent!.render(canvas,
        'FPS: ${double.parse(fps.toStringAsFixed(4))}', Vector2(50, 50));
    if (countPoints >= 0) {
      textFpsComponent!
          .render(canvas, 'Points: $countPoints', Vector2(size.x - 150, 50));
    } else {
      textFpsComponent!.render(canvas, 'Points: 0', Vector2(size.x - 150, 50));
    }
  }

  @override
  Future<void> onLoad() async {
    circleBlue = circle.CircleComponent(
      position: Vector2((size.x / 4) * 1, 500),
      paint: BasicPalette.blue.paint(),
      speed: 2.5,
      angle: pi,
      centerX: size.x / 2,
      centerY: size.y / 4 * 3,
      calcX: sin,
      calcY: cos,
    );

    circleRed = circle.CircleComponent(
      position: Vector2((size.x / 4) * 1, 500),
      paint: BasicPalette.red.paint(),
      speed: 2.5,
      angle: 0,
      centerX: size.x / 2,
      centerY: size.y / 4 * 3,
      calcX: sin,
      calcY: cos,
    );

    startRectangleTimer();

    lines = [
      Line(startX: 0, startY: 0, endX: size.x, endY: 0),
      Line(startX: 0, startY: 0, endX: size.x, endY: 0),
      Line(startX: 0, startY: 0, endX: size.x, endY: 0),
      Line(startX: 0, startY: 0, endX: size.x, endY: 0),
      Line(startX: 0, startY: 0, endX: size.x, endY: 0),
      Line(startX: 0, startY: 0, endX: size.x, endY: 0),
    ];

    initializeCollisionDetection(
      mapDimensions: Rect.fromLTWH(0, 0, size.x, size.y),
      minimumDistance: 10,
    );

    textComponent = TextPaint(
      style: const TextStyle(
        fontSize: 48.0,
        fontFamily: 'Awesome Font',
        color: Colors.red,
        fontWeight: FontWeight.bold,
      ),
    );

    textFpsComponent = TextPaint(
      style: const TextStyle(
        fontSize: 20.0,
        fontFamily: 'Awesome Font',
        color: Colors.white,
      ),
    );

    return super.onLoad();
  }

  void startRectangleTimer() {
    rectangleTimer = ASYNC.Timer.periodic(const Duration(seconds: 1), (_) {
      generateRectangle();
    });
  }

  void generateRectangle() {
    const rectangleWidth = 75.0;
    const rectangleHeight = 35.0;

    double rectangleX = (size.x / 2) - rectangleWidth / 2 - 100;
    double rectangleY = (size.y / 2) - size.y / 2;

    int randomNumber = random.nextInt(3) + 1;

    if (randomNumber == 1) {
      rectangleX = (size.x / 2) - rectangleWidth / 2 + 75;
      rectangleY = (size.y / 2) - size.y / 2;
    }
    if (randomNumber == 2) {
      rectangleX = (size.x / 2) - rectangleWidth / 2;
      rectangleY = (size.y / 2) - size.y / 2;
    }
    if (index + 1 < 10) {
      index++;
    } else {
      index = 0;
    }
    rectangles.add(
      rectangle.RectangleComponent(
        height: rectangleHeight,
        width: rectangleWidth,
        x: rectangleX,
        y: rectangleY,
        speed: rectangleSpeed,
        paint: BasicPalette.white.paint(),
      ),
    );

    countPoints++;

    if (rectangles.length > 10) {
      rectangles.removeAt(1);
    }
  }

  void stopRectangleTimer() {
    rectangleTimer?.cancel();
  }

  @override
  void onDetach() {
    stopRectangleTimer();
    super.onDetach();
  }
}
