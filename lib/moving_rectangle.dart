import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class MovingRectangle extends PositionComponent {
  @override
  double width;
  @override
  double height;
  double speed;
  Paint paint;

  MovingRectangle(
      {required double x,
      required double y,
      required this.width,
      required this.height,
      required this.speed,
      required this.paint}) {
    position = Vector2(x, y);
    size = Vector2(width, height);
  }

  @override
  void update(double dt) {
    // Actualizar la posición del rectángulo según la velocidad
    position.y += speed * dt;
  }

  @override
  void render(Canvas canvas) {
    super.render(
        canvas); // Llamar a super.render(canvas) para renderizar el componente
    canvas.drawRect(toRect(), paint);
  }
}

class RectangleComponent extends PositionComponent with HasCollisionDetection {
  @override
  double width;
  @override
  double height;
  double speed;
  Paint paint;

  RectangleComponent(
      {required double x,
      required double y,
      required this.width,
      required this.height,
      required this.speed,
      required this.paint}) {
    position = Vector2(x, y);
    size = Vector2(width, height);
  }

  @override
  void update(double dt) {
    // Actualizar la posición del rectángulo según la velocidad
    position.y += speed * dt;
  }

  @override
  FutureOr<void> onLoad() {
    add(RectangleHitbox());
    return super.onLoad();
  }

  @override
  void render(Canvas canvas) {
    super.render(
        canvas); // Llamar a super.render(canvas) para renderizar el componente
    canvas.drawRect(toRect(), paint);
  }
}
