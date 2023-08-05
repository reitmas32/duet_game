import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
// ignore: library_prefixes
import 'dart:async' as ASYNC;
import 'package:first_game/moving_rectangle.dart' as rectangle;

class CircleComponent extends PositionComponent
    with HasCollisionDetection, CollisionCallbacks {
  final double radius;
  Paint paint;
  double speed;
  @override
  double angle;
  double centerX;
  double centerY;
  bool onRotateLeft;
  bool onRotateRigth;
  double Function(double) calcX;
  double Function(double) calcY;

  CircleComponent(
      {required this.paint,
      required this.angle,
      required this.centerX,
      required this.centerY,
      required this.calcX,
      required this.calcY,
      this.onRotateLeft = false,
      this.onRotateRigth = false,
      this.speed = 2,
      this.radius = 75,
      super.position}) {
    double newCenterX = centerX + calcX(angle) * radius;
    double newCenterY = centerY + calcY(angle) * radius;
    position.x = newCenterX;
    position.y = newCenterY;
  }

  @override
  ASYNC.FutureOr<void> onLoad() {
    add(RectangleHitbox());
    return super.onLoad();
  }

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(Offset(position.x, position.y), 10, paint);
  }

  @override
  void update(double dt) {
    // Actualizar la posición del rectángulo según la velocidad
    if (onRotateLeft) {
      angle += speed * dt;
      double newCenterX = centerX + sin(angle) * radius;
      double newCenterY = centerY + cos(angle) * radius;
      position.x = newCenterX;
      position.y = newCenterY;
    }
    if (onRotateRigth) {
      angle -= speed * dt;
      double newCenterX = centerX + sin(angle) * radius;
      double newCenterY = centerY + cos(angle) * radius;
      position.x = newCenterX;
      position.y = newCenterY;
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is rectangle.RectangleComponent &&
        checkCollision(x, y, 4, other.x, other.y, other.width, other.height)) {}
  }

  bool onCheckCollision(PositionComponent other) {
    if (other is rectangle.RectangleComponent &&
        checkCollision(x, y, 4, other.x, other.y, other.width, other.height)) {
      return true;
    }
    return false;
  }

  bool checkCollision(
    double circleCenterX,
    double circleCenterY,
    double circleRadius,
    double rectX,
    double rectY,
    double rectWidth,
    double rectHeight,
  ) {
    // Comprueba si el centro del círculo está dentro del rectángulo
    if (circleCenterX >= rectX &&
        circleCenterX <= rectX + rectWidth &&
        circleCenterY >= rectY &&
        circleCenterY <= rectY + rectHeight) {
      return true;
    }

    // Calcula la distancia horizontal más cercana entre el centro del círculo y el rectángulo
    double distX = max(rectX - circleCenterX, 0) +
        max(circleCenterX - (rectX + rectWidth), 0);

    // Calcula la distancia vertical más cercana entre el centro del círculo y el rectángulo
    double distY = max(rectY - circleCenterY, 0) +
        max(circleCenterY - (rectY + rectHeight), 0);

    // Comprueba si hay colisión en el eje x y el eje y
    if (distX <= circleRadius && distY <= circleRadius) {
      return true;
    }

    return false;
  }
}
