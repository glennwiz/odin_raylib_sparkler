package rayThing

import "core:fmt"
import "core:time"
import rand "core:math/rand"
import "core:os"
import rl "vendor:raylib"

WINDOW_SIZE :: 1000
GRID_WIDTH :: 80
GRID_HEIGHT :: 100
VEC2_LOCATION :: [2]int

CELL_SIZE :: WINDOW_SIZE / GRID_WIDTH

eater: VEC2_LOCATION;



main :: proc(){
    fmt.println("Hello, World!")

    rl.InitWindow(WINDOW_SIZE, WINDOW_SIZE, "2D Flame");
    rl.SetTargetFPS(60);

    grid := make([][GRID_WIDTH]int, GRID_HEIGHT)
    defer delete(grid)
   
    for !rl.WindowShouldClose(){
        //we need to update the flame
        update_flame(&grid);


        rl.BeginDrawing();
        rl.ClearBackground(rl.BLACK);
        

        //Draw the flame
        draw_flame(grid);


        //Flashing Cell at the center
        color := PickColor();        
        cell_rect := rl.Rectangle{WINDOW_SIZE / 2, WINDOW_SIZE / 2, CELL_SIZE, CELL_SIZE};
                    
        rl.DrawRectangleRec(cell_rect, color);        
        rl.EndDrawing();       
    }

    rl.CloseWindow();
}

update_flame :: proc(grid: ^[][GRID_WIDTH]int) {
    fmt.println("Updating Flame")
}

draw_flame :: proc(grid: [][GRID_WIDTH]int) {
    fmt.println("Drawing Flame")
}

PickColor :: proc() -> rl.Color {   
    return rl.Color{
        u8(rand.int_max(256)),
        u8(rand.int_max(256)),
        u8(rand.int_max(256)),
        255,
    }
}

