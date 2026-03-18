import 'dart:io';

Future<String> LoadMap() async {
  const file_path = 'map.txt';
  try {
    String map = await File(file_path).readAsString();
    return map;
  } catch (e) {
    print('error on open file, msg: $e');
    return '';
  }
}

// x,y
int LineLenght(String target) {
  int len = 0;
  for (int i = 0; i < target.length; i++) {
    if (target[i] == '\n') {
      len = i - 1;
      break;
    }
  }
  return len;
}

Coordinat FindPlayerPos(String map, int row_len) {
  row_len += 2;
  int player_len = 0;
  for (int i = 0; i < map.length; i++) {
    if (map[i] == 'P') {
      player_len = i;
      break;
    }
  }
  return Coordinat(player_len % row_len, (player_len / row_len).truncate());
}

class Coordinat {
  int x;
  int y;
  Coordinat(this.x, this.y);
}

enum MoveState { Valid, Invalid, Win }

class Maze {
  String map;
  int line_len = 0;
  bool running = true;
  Coordinat player_pos = Coordinat(0, 0);
  Maze(this.map) {
    this.line_len = LineLenght(this.map);
    this.player_pos = FindPlayerPos(this.map, this.line_len);
  }
  MoveState IsValidMove(int x, int y) {
    // player_len % row_len, player_len / row_len
    print(x + y * (this.line_len + 2));
    switch (this.map[x + y * (this.line_len + 2)]) {
      case '#':
        return MoveState.Invalid;
      case '@':
        return MoveState.Win;
      default:
        return MoveState.Valid;
    }
  }

  void ChangePlayerPos(int x, int y) {
    int index_old = this.player_pos.x + this.player_pos.y * (this.line_len + 2);
    this.player_pos.x += x;
    this.player_pos.y += y;
    int index_new = this.player_pos.x + this.player_pos.y * (this.line_len + 2);
    if (index_old > index_new) {
      this.map =
          map.substring(0, index_new) +
          'P' +
          map.substring(index_new + 1, index_old) +
          ' ' +
          map.substring(index_old + 1);
    } else {
      this.map =
          map.substring(0, index_old) +
          ' ' +
          map.substring(index_old + 1, index_new) +
          'P' +
          map.substring(index_new + 1);
    }
  }

  void Move(int x, int y) {
    // U, D, R, L
    MoveState move_state = IsValidMove(
      this.player_pos.x + x,
      this.player_pos.y + y,
    );
    switch (move_state) {
      case MoveState.Valid:
        ChangePlayerPos(x, y);
        print(map);
        print('Success Move');
        break;
      case MoveState.Invalid:
        print('Invalid Move!');
        break;
      case MoveState.Win:
        print('Congratulation, You Win!');
        this.running = false;
        break;
    }
  }

  void ListenInput() {
    String user_input = stdin.readLineSync() ?? '';
    switch (user_input) {
      case 'U':
        Move(0, -1);
        break;
      case 'D':
        Move(0, 1);
        break;
      case 'R':
        Move(1, 0);
        break;
      case 'L':
        Move(-1, 0);
        break;
      case 'exit':
        this.running = false;
        break;
      default:
        print('Invalid input');
        break;
    }
  }

  void Run() {
    print(map);
    while (this.running) {
      ListenInput();
    }
    print('See you again');
  }
}

Future<void> main() async {
  String map = await LoadMap();
  Maze maze = Maze(map);
  maze.Run();
}
