package rayThing

import "core:fmt"
import "core:time"
import "core:math"
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

        //fmt docs odin/core/fmt/docs.odin
        fmt.printf("Grid memory address: %p\n", &grid)

        //we need to update the flame
        update_flame(grid);


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

update_flame :: proc(grid: [][GRID_WIDTH]int) {    

    // x is the row, Under skjørtet
    // y is the column, Og så oppover

    // 5y    5
    // 4y   4
    // 3y  3
    // 2y 2
    // 1y1
    // 0 xxxxxxxxx
    //   123456789
    
    
    // fill bottom row with random values    
    for x in 0..<GRID_WIDTH {
        grid[GRID_HEIGHT-1][x] = rand.int_max(256)
    }     

    // Update cells
    for y in 1..<GRID_HEIGHT {
        for x in 0..<GRID_WIDTH {
            index := GRID_HEIGHT - y
            left := max(x - 1, 0)
            right := min(x + 1, GRID_WIDTH - 1)
            
            /* 
               Calculate new value with heat diffusion algorithm
               this is a kind of cellular automata
               we are updating the value of the cell based on the values of the cells around it
               the new value is the average of the cell and its neighbors  
               4 cells in total, 1 above and 3 to the sides     
           
               The neighbors considered are:

                    The cell to the left
                    The cell itself
                    The cell to the right
                    The cell below
            */   

            new_value := (
                grid[index][left] +
                grid[index][x] +
                grid[index][right] +
                grid[index-1][x]
            ) / 4

            if new_value > 0 {
                //fmt.printf("New value: %d\n", new_value)
            }     

                      
            grid[index-1][x] = max(0, new_value - rand.int_max(3))
        }
    }
}

draw_flame :: proc(grid: [][GRID_WIDTH]int) {
    for y in 0..<GRID_HEIGHT {
        for x in 0..<GRID_WIDTH {
            value := grid[y][x]
            
            //purple tones
            color := rl.Color{u8(value), u8(value/2), u8(value), 255}
            rl.DrawRectangle(
                i32(x * CELL_SIZE), 
                i32(y * CELL_SIZE), 
                i32(CELL_SIZE), 
                i32(CELL_SIZE), 
                color
            )
        }
    }
}

PickColor :: proc() -> rl.Color {   
    return rl.Color{
        u8(rand.int_max(256)),
        u8(rand.int_max(256)),
        u8(rand.int_max(256)),
        255,
    }
}