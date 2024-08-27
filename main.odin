package rayThing

import "core:fmt"
import "core:time"
import rand "core:math/rand"
import "core:os"
import rl "vendor:raylib"

WINDOW_SIZE :: 1000
GRID_SIZE :: 10
CELL_SIZE :: 10
VEC2_LOCATION :: [2]int

CANVAS_SIZE :: GRID_SIZE * CELL_SIZE;

eater: VEC2_LOCATION;


main :: proc(){
    fmt.println("Hello, World!")

    rl.InitWindow(WINDOW_SIZE, WINDOW_SIZE, "Raylib test");


   

    for !rl.WindowShouldClose(){
        rl.BeginDrawing();
        rl.ClearBackground(rl.DARKGREEN);

        color := PickColor();

        //Flashing Cell at the center
        cell_rect := rl.Rectangle{WINDOW_SIZE / 2, WINDOW_SIZE / 2, CELL_SIZE, CELL_SIZE};

                    
        rl.DrawRectangleRec(cell_rect, color);
        
        rl.EndDrawing();

       
    }

    rl.CloseWindow();
}

PickColor :: proc() -> rl.Color {   
    return rl.Color{
        u8(rand.int_max(256)),
        u8(rand.int_max(256)),
        u8(rand.int_max(256)),
        255,
    }
}

