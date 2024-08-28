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

CellType :: enum u8 {
    EMPTY,
    ELECTRON_HEAD,
    ELECRON_TAIL,
    CONDUCTOR,
}

Cell :: struct {
    cell_type: CellType,
    value: int
}


main :: proc(){
    fmt.println("Hello, World!")


    rl.InitWindow(WINDOW_SIZE, WINDOW_SIZE, "2D Flame");
    rl.SetTargetFPS(60);

    grid := make([][GRID_WIDTH]Cell, GRID_HEIGHT)
    defer delete(grid)

    initialize_grid(&grid)
   
    for !rl.WindowShouldClose(){       

        if rl.IsMouseButtonPressed(.LEFT) {
            fmt.println("Left Mouse button pressed")

            mouse_pos := rl.GetMousePosition()
            x := int(mouse_pos.x) / CELL_SIZE
            y := int(mouse_pos.y) / CELL_SIZE

            fmt.printf("Mouse position: %d, %d\n", x, y)
            place_conductor(&grid)
        }
        if rl.IsMouseButtonPressed(.RIGHT) {
            fmt.println("Right Mouse button pressed")
            place_electron(&grid)
        }

        //fmt docs odin/core/fmt/docs.odin
        //fmt.printf("Grid memory address: %p\n", &grid)

        //we need to update the flame
        update_flame(grid);


        rl.BeginDrawing();
        rl.ClearBackground(rl.BLACK);
        

        //Draw the flame
        draw_flame(grid);


        //Draw the grid
        for y in 0..<GRID_HEIGHT {
            for x in 0..<GRID_WIDTH {
                cell := grid[y][x]
                color := rl.WHITE

                if cell.cell_type == .CONDUCTOR {
                    color = rl.YELLOW
                } else if cell.cell_type == .ELECTRON_HEAD {
                    color = rl.BLUE
                } else if cell.cell_type == .ELECRON_TAIL {
                    color = rl.RED
                }

                if(color != rl.WHITE)
                {
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

        //Flashing Cell at the center
        color := PickColor();        
        cell_rect := rl.Rectangle{WINDOW_SIZE / 2, WINDOW_SIZE / 2, CELL_SIZE, CELL_SIZE};
                    
        rl.DrawRectangleRec(cell_rect, color);        
        rl.EndDrawing();       
    }

    rl.CloseWindow();
}

initialize_grid :: proc(grid: ^[][GRID_WIDTH]Cell) {
    for y in 0..<GRID_HEIGHT {
        for x in 0..<GRID_WIDTH {
            grid[y][x].cell_type = .EMPTY
        }
    }

    // Create an initial pattern (a simple wire with an electron)
    mid_y := GRID_HEIGHT / 2
    for x in GRID_WIDTH/4..=(3*GRID_WIDTH)/4 {
        grid[mid_y][x].cell_type = .CONDUCTOR
    }
    grid[mid_y][GRID_WIDTH/4].cell_type = .ELECTRON_HEAD
}

update_flame :: proc(grid: [][GRID_WIDTH]Cell) {    

    // x is the row, Under skjørtet
    // y is the column, Og så oppover

    // y     5
    // y    4
    // y   3
    // y  2
    // y 1
    // y0
    //  xxxxxxxxx  
    
    // fill bottom row with random values    
    for x in 0..<GRID_WIDTH {
        grid[GRID_HEIGHT-1][x].value = rand.int_max(256)
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
                grid[index][left].value +
                grid[index][x].value +
                grid[index][right].value +
                grid[index-1][x].value
            ) / 4

            if new_value > 0 {
                //fmt.printf("New value: %d\n", new_value)
            }     

                      
            grid[index-1][x].value = max(0, new_value - rand.int_max(3))
        }
    }
}

draw_flame :: proc(grid: [][GRID_WIDTH]Cell) {
    for y in 0..<GRID_HEIGHT {
        for x in 0..<GRID_WIDTH {
            cell := grid[y][x]
            
            //purple tones
            color := rl.Color{u8(cell.value), u8(cell.value/2), u8(cell.value), 255}
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

place_conductor :: proc(grid: ^[][GRID_WIDTH]Cell) {
    mouse_pos := rl.GetMousePosition()
    x := int(mouse_pos.x) / CELL_SIZE
    y := int(mouse_pos.y) / CELL_SIZE

    fmt.printf("placing_conductor: %d, %d\n", x, y)

    if x >= 0 && x < GRID_WIDTH && y >= 0 && y < GRID_HEIGHT {
        grid[y][x].cell_type = .CONDUCTOR
    }
}

place_electron :: proc(grid: ^[][GRID_WIDTH]Cell) {
    mouse_pos := rl.GetMousePosition()
    x := int(mouse_pos.x) / CELL_SIZE
    y := int(mouse_pos.y) / CELL_SIZE

    fmt.printf("placing_electron: %d, %d\n", x, y)

    if x >= 0 && x < GRID_WIDTH && y >= 0 && y < GRID_HEIGHT {
        if grid[y][x].cell_type == .CONDUCTOR {            

            grid[y][x].cell_type = .ELECTRON_HEAD
        }
    }
}