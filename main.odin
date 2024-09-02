package rayThing

import "core:fmt"
import "core:time"
import "core:math"
import "core:os"
import rand "core:math/rand"
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
    ELECTRON_TAIL,
    CONDUCTOR,
}

Cell :: struct {
    cell_type: CellType,
    value: int
}

Point :: struct {
    x, y: int
}

is_drawing := false
is_erasing := false
is_updating := false
speed := 60
last_draw_pos: VEC2_LOCATION

playground :: proc(){
    ddd : ^int //declare a pointer to an integer
    iii := 369 //declare an integer
    ddd = &iii //assign the address of iii to ddd

    fmt.printf("ddd (address): %p\n", ddd) 
    fmt.printf("ddd (value): %d\n", ddd^)

    fmt.printf("iii (address): %p\n", &iii)
    fmt.printf("iii (value): %d\n", iii)
}

main :: proc(){
    fmt.println("Hello, World!") 

    // Raylib setup
    rl.InitWindow(WINDOW_SIZE, WINDOW_SIZE, "2D Flame");
    rl.SetTargetFPS(60);

    //playground
    playground();

    grid := make([][GRID_WIDTH]Cell, GRID_HEIGHT)
    defer delete(grid)

    initialize_grid(grid)
   
    counter := 0
    for !rl.WindowShouldClose(){       

        if rl.IsKeyPressed(.SPACE) {
            is_updating = !is_updating
        }
       
        update_input(grid)     


        electron_heads := find_electron_heads(grid)
        fmt.printf("Number of electron heads: %d\n", len(electron_heads))
        defer delete(electron_heads)

        counter += 1;
        //check counter against modulus 0
        if(is_updating == true && counter % speed == 0)
        {        
            update_grid(grid)
        }
        
        //fmt docs odin/core/fmt/docs.odin
        //fmt.printf("Grid memory address: %p\n", &grid)

        update_flame(grid);
        rl.BeginDrawing();
        rl.ClearBackground(rl.BLACK);    
        draw_flame(grid);

        //grow the  conductor
        if counter % 100 == 0 {
            fmt.printf("Counter: %d\n", counter)
            grow_conductor(grid)
        }
        fmt.printf("Counter: %d\n", counter)
        //grow_conductor(grid);

        //Draw the grid
        for y in 0..<GRID_HEIGHT {
            for x in 0..<GRID_WIDTH {
                cell := grid[y][x]
                color := rl.WHITE

                if cell.cell_type == .CONDUCTOR {
                    color = rl.YELLOW
                } else if cell.cell_type == .ELECTRON_HEAD {
                    color = rl.BLUE
                } else if cell.cell_type == .ELECTRON_TAIL {
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

grow_conductor :: proc(grid: [][GRID_WIDTH]Cell) {
    //find the end of the conductor
    for y in 0..<GRID_HEIGHT {
        for x in 0..<GRID_WIDTH {
            if grid[y][x].cell_type == .CONDUCTOR {
                fmt.printf("Conductor found at: %d, %d\n", x, y)
                
                // count the number of conductor cells around the cell
                left := x - 1
                right := x + 1
                up := y - 1
                down := y + 1                

                count := 0
                i := 8 //number of cells around the cell

                if grid[y][left].cell_type == .CONDUCTOR {
                    count += 1
                }
                
                if grid[y][right].cell_type == .CONDUCTOR {
                    count += 1
                }

                if(y > 0){
                    if grid[up][x].cell_type == .CONDUCTOR {
                        count += 1
                    }
                }
                    
                if grid[down][x].cell_type == .CONDUCTOR {
                    count += 1
                }

                //check if the cell above is empty
                if y > 0 && grid[y-1][x].cell_type == .EMPTY  && count == 1  && y < GRID_HEIGHT - 1 {
                    direction := rand.int_max(4)    

                    
                    random_number := rand.int_max(2)
                    ramdom_number2 := rand.int_max(2)
                    if(direction == 0){
                        grid[y-1][x].cell_type = .CONDUCTOR
                    } else if(direction == 1){
                        grid[y-1][x+random_number].cell_type = .CONDUCTOR
                    } else if(direction == 2){
                        grid[y-1][x-random_number].cell_type = .CONDUCTOR
                    } else if(direction == 3){
                        grid[y-1][x+random_number].cell_type = .CONDUCTOR
                        grid[y-1][x-random_number].cell_type = .CONDUCTOR
                    }
                    //grid[y-random_number][x-random_number].cell_type = .CONDUCTOR
                }
                count = 0
            }
        }   
    }
}

find_electron_heads :: proc(grid: [][GRID_WIDTH]Cell) -> []Point {
    electron_heads := make([dynamic]Point)
   
    for y in 0..<GRID_HEIGHT {
        for x in 0..<GRID_WIDTH {
            if y < GRID_HEIGHT  {           
                 if grid[y][x].cell_type == .ELECTRON_HEAD {
                    append(&electron_heads, Point{x, y})
                }
            }
        }

    }

    return electron_heads[:] //returning a slice, shorthand for electron_heads[0:len(electron_heads)]
} 

initialize_grid :: proc(grid: [][GRID_WIDTH]Cell) {
    for y in 0..<GRID_HEIGHT {
        for x in 0..<GRID_WIDTH {
            grid[y][x].cell_type = .EMPTY
        }
    }

    // Create an initial pattern (a simple wire with an electron)    
    // wireworld

    //line top
    mid_y_top_two := GRID_HEIGHT / 2 - 2
    for x in GRID_WIDTH/4..=(3*GRID_WIDTH)/4 {
        grid[mid_y_top_two][x].cell_type = .CONDUCTOR
    }
    //line bottom
    mid_y := GRID_HEIGHT / 2
    for x in GRID_WIDTH/4..=(3*GRID_WIDTH)/4 {
        grid[mid_y][x].cell_type = .CONDUCTOR
    }
   
    //the starting electron
    grid[mid_y][GRID_WIDTH/2].cell_type = .ELECTRON_HEAD

    //end caps
    mid_y_end_caps := GRID_HEIGHT / 2 -1
    grid[mid_y_end_caps][GRID_WIDTH/4 + 1].cell_type = .CONDUCTOR    
}

update_input :: proc(grid: [][GRID_WIDTH]Cell) {
    mouse_pos := rl.GetMousePosition()
    x := int(mouse_pos.x) / CELL_SIZE
    y := int(mouse_pos.y) / CELL_SIZE

    if x >= 0 && x < GRID_WIDTH && y >= 0 && y < GRID_HEIGHT {
        current_pos := VEC2_LOCATION{x, y}

        if rl.IsMouseButtonDown(.LEFT) {
            if !is_drawing {
                is_drawing = true
                is_erasing = false
                last_draw_pos = current_pos
            }
            draw_line(grid, last_draw_pos, current_pos, .CONDUCTOR)
            last_draw_pos = current_pos
        } else if rl.IsMouseButtonReleased(.LEFT) {
            is_drawing = false
        }

        if rl.IsMouseButtonDown(.RIGHT) {
            if !is_erasing {
                is_erasing = true
                is_drawing = false
                last_draw_pos = current_pos
            }
            draw_line(grid, last_draw_pos, current_pos, .EMPTY)
            last_draw_pos = current_pos
        } else if rl.IsMouseButtonReleased(.RIGHT) {
            is_erasing = false
        }

        if rl.IsMouseButtonPressed(.MIDDLE) {
            place_electron(grid)
        }
    }

    if rl.IsKeyPressed(.SPACE) {
        update_grid(grid)
    }

    if rl.IsKeyPressed(.PERIOD){
        if speed > 10 {
            speed -= 10
        }        
    }

    if rl.IsKeyPressed(.COMMA){
        if speed < 100 {
            speed += 10
        }
    }
}

draw_line :: proc(grid: [][GRID_WIDTH]Cell, start, end: VEC2_LOCATION, cell_type: CellType) {
    dx := abs(end.x - start.x)
    dy := -abs(end.y - start.y)
    sx := start.x < end.x ? 1 : -1
    sy := start.y < end.y ? 1 : -1
    err := dx + dy

    x, y := start.x, start.y

    for {
        if x >= 0 && x < GRID_WIDTH && y >= 0 && y < GRID_HEIGHT {
            grid[y][x].cell_type = cell_type
        }

        if x == end.x && y == end.y do break

        e2 := 2 * err
        if e2 >= dy {
            err += dy
            x += sx
        }
        if e2 <= dx {
            err += dx
            y += sy
        }
    }
}


update_grid :: proc(grid: [][GRID_WIDTH]Cell) {
    new_grid := make([][GRID_WIDTH]Cell, GRID_HEIGHT)
    defer delete(new_grid)

    for y in 0..<GRID_HEIGHT {
        for x in 0..<GRID_WIDTH {

            c := grid[y][x]

            switch c.cell_type {
            case .EMPTY:
                new_grid[y][x].cell_type = .EMPTY
                new_grid[y][x].value = c.value
            case .ELECTRON_HEAD:
                new_grid[y][x].cell_type = .ELECTRON_TAIL
            case .ELECTRON_TAIL:
                new_grid[y][x].cell_type = .CONDUCTOR
            case .CONDUCTOR:
                count := count_electron_heads(grid, x, y)
                //creating new heads
                new_grid[y][x].cell_type = count == 1 || count == 2 ? .ELECTRON_HEAD : .CONDUCTOR
            }
        }
    }

    for y in 0..<GRID_HEIGHT {
        for x in 0..<GRID_WIDTH {
            grid[y][x] = new_grid[y][x]
        }
    }
}

count_electron_heads :: proc(grid: [][GRID_WIDTH]Cell, x, y: int) -> int {
    //we look at the number of electron heads around the cell
    //we are looking at the 8 cells around the cell
    //we are not looking at the cell itself  
    
    //if 1 or 2 electron heads are around the cell, the cell will become a new electron head

    //find closest cell that is an electron head
    centerX := GRID_WIDTH / 2
    centerY := GRID_HEIGHT / 2

    fmt.printf("centerX: %d, centerY: %d\n", centerX, centerY)



    count := 0
    for dy in -1..=1 {
        for dx in -1..=1 {
            if dx == 0 && dy == 0 do continue
            nx, ny := x + dx, y + dy
            if nx >= 0 && nx < GRID_WIDTH && ny >= 0 && ny < GRID_HEIGHT {
                if grid[ny][nx].cell_type == .ELECTRON_HEAD do count += 1
            }
        }
    }
    return count
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

            index := GRID_HEIGHT - y
            left := max(x - 1, 0)
            right := min(x + 1, GRID_WIDTH - 1)

            new_value := (
                grid[index][left].value +
                grid[index][x].value +
                grid[index][right].value +
                grid[index-1][x].value
            ) / 4
      
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

place_electron :: proc(grid: [][GRID_WIDTH]Cell) {
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