
var canvas;
var g;

var recipe = [];
var recipeStep = -1;
var stepComplete = false;

setInterval(() => {
    if(recipe.length <= 0) return;
    if(!stepComplete) return;

    if(gachaneitor_status.sound) {
        gachaneitor_status.sound.pause();
        gachaneitor_status.sound = null;
    }
    stepComplete = false;
    recipeStep++;
    if(recipeStep < recipe.length) {
        timeOutCallback = null;
        console.log("Step: " + recipe[recipeStep]);
        eval(recipe[recipeStep]);
    }
}, 200);

function loadGachacode() {
    var fileInput = document.getElementById("gachacode-file");
    fileInput.value = "";
    fileInput.oninput = e => {
        var file = e.target.files[0];

        var fileReader = new FileReader();
        fileReader.onload = (e) => {
            recipe = e.target.result.split('\n').filter((step) => step);
            recipeStep = -1;
            stepComplete = true;
        };
        fileReader.onerror = (e) => {
            alert(e.target.error.name);
        };
        fileReader.readAsText(file, 'UTF-8');
    }
    fileInput.click();
}

function program(temp, speed, time, reverse=false) {
    console.log(`programming at ${temp}C, blade speed ${speed}, ${time} seconds${reverse ? ' [reverse]' : ''}`);

    gachaneitor_status.temp = temp;

    gachaneitor_status.speed = speed;

    var minutes = Math.floor(time / 60);
    var seconds = time % 60;
    gachaneitor_status.time[0] = minutes;
    gachaneitor_status.time[1] = seconds;
    gachaneitor_status.time_target[0] = minutes;
    gachaneitor_status.time_target[1] = seconds;

    timeOutCallback = () => stepComplete = true;

    changeScreen(SCREEN.PROGRAM);
}

/*function heat(temp, time) {
    program(temp, 0, time);
}

function stir(speed, time, reverse=falase) {
    program(0, speed, time, reverse);
}*/

function add(ingredient) {
    console.log(`Add ${ingredient}`);

    gachaneitor_status.screen_properties.add.ingredient_name = ingredient;
    changeScreen(SCREEN.ADD);
}

function take(content) {
    console.log(`Take ${content} from the Gachaneitor Bowl`);

    gachaneitor_status.screen_properties.take.content = content;
    gachaneitor_status.sound = new Audio('audio/take.mp3');
    gachaneitor_status.sound.play();
    changeScreen(SCREEN.TAKE);
}

function useraction(action) {
    console.log(`[USER] ${action}`);

    gachaneitor_status.screen_properties.useraction.action = action;
    changeScreen(SCREEN.USER_ACTION);
}


function setup() {
    // Initialize canvas and graphics context
    canvas = document.getElementById("gachaneitor");
    g = canvas.getContext("2d");

    // Overlays setup
    g_config.cover_x = canvas.width*0.25;
    g_config.cover_y = canvas.width*0;
    g_config.cover_width = canvas.width*0.5;
    g_config.cover_height = canvas.height*0.6;

    g_config.screen_x  = canvas.width  * 0.258;
    g_config.screen_y  = canvas.height * 0.654;
    g_config.screen_width  = canvas.width  * 0.478;
    g_config.screen_height = canvas.height * 0.26;

    g_config.dial_big.box_size = g_config.screen_width/3.1;
    g_config.dial_small.box_size = g_config.screen_width/4;

    // Set image sources
    g_config.take_img.src = "img/take.png";
    g_config.add_img.src = "img/add.png";
    g_config.useraction_img.src = "img/useraction.png";
    g_config.time_symbol_img.src = "img/time.png";
    g_config.speed_symbol_img.src = "img/speed.png";
    g_config.cover_img.onload = () => {
        redraw(g_config);
        window.setInterval(onDraw, 33);
    };
    
    g_config.base_img.onload = () => {
        g_config.cover_img.src = "img/gachaneitorCover.png";
    }
    g_config.base_img.src = "img/gachaneitorBase.png";
    
    
    window.setInterval(updateTime, 1000);

    canvas.addEventListener('click', (e)  => {
        var rect = canvas.getBoundingClientRect();
        onMouseClick({
            x: e.clientX - rect.left,
            y: e.clientY - rect.top,
            detail: e.detail
        });
    }, false);

    canvas.addEventListener('mousemove', (e)  => {
        var rect = canvas.getBoundingClientRect();
        onMouseMove({
            x: e.clientX - rect.left,
            y: e.clientY - rect.top
        });
    }, false);
}

function onMouseClick(e) {
    switch(gachaneitor_status.screen) {
        case SCREEN.PROGRAM:
            var new_selection;
            if(e.x >= g_config.screen_x && e.x <= g_config.screen_x + g_config.screen_width
                && e.y >= g_config.screen_y && e.y <= g_config.screen_y + g_config.screen_height) {
                    new_selection = SCREEN_PROGRAM_ITEMS[Math.trunc(3*(1/3+(e.x - g_config.screen_x)/g_config.screen_width))];
            } else {
                new_selection = SCREEN_PROGRAM_ITEMS[0];
            }
            if(gachaneitor_status.screen_properties.program.selected != new_selection) {
                gachaneitor_status.screen_properties.program.selected = new_selection;
                gachaneitor_status.invalidated = true;
            } else if(new_selection == 'time' && e.detail === 2) {
                stepComplete = true;
            }
            break;
        case SCREEN.ADD:
        case SCREEN.TAKE:
        case SCREEN.USER_ACTION:
            stepComplete = true;
            break;
    }
}

function onMouseMove(e) {
    if(e.x >= g_config.cover_x && e.x <= g_config.cover_x + g_config.cover_width
        && e.y >= g_config.cover_y && e.y <= g_config.cover_y + g_config.cover_height) {
            if(g_config.cover_shown) {
                g_config.cover_shown = false;
                redraw(g_config);
            }
    } else {
        if(!g_config.cover_shown) {
            g_config.cover_shown = true;
            redraw(g_config);
        }
    } 
}

var timeOutCallback = null;
function updateTime() {
    if(gachaneitor_status.time[0] == 0 && gachaneitor_status.time[1] == 0) {
        if(timeOutCallback) timeOutCallback();
        timeOutCallback = null;
        return;
    }
    
    if(gachaneitor_status.time[1] == 0) {
        gachaneitor_status.time[0] -= 1;
        gachaneitor_status.time[1] = 59; 
    } else {
        gachaneitor_status.time[1] -= 1;
    }
}

const SCREEN = {
    PROGRAM: 'program',
    ADD: 'add',
    TAKE: 'take',
    USER_ACTION: 'useraction'
};
var SCREEN_PROGRAM_ITEMS = ['none', 'time', 'temp', 'speed'];

var gachaneitor_status = {
    sound: null,
    speed: 0,
    temp: 0,
    time: [0, 0],
    time_target: [10, 0],
    screen: SCREEN.PROGRAM,
    screen_properties: {
        program: {
            selected: SCREEN_PROGRAM_ITEMS[2]
        },
        add: {
            ingredient_name: ""
        },
        take: {
            content: ""
        },
        useraction: {
            action: ""
        }
    },
    invalidated: false
};

var g_config = {
    base_img: new Image(),
    cover_img: new Image(),
    take_img: new Image(),
    add_img: new Image(),
    useraction_img: new Image(),
    cover_shown: true,
    cover_x: -1,
    cover_y: -1,
    cover_width: 0,
    cover_height: 0,
    screen_x: -1,
    screen_y: -1,
    screen_width: 0,
    screen_height: 0,
    screen_background_color: "#EEEEEE",
    temp_min: 30,
    temp_max: 120,
    speed_min: 0,
    speed_max: 10,
    time_symbol_img: new Image(),
    speed_symbol_img: new Image(),
    time_bar: {
        offset: 0.05,
        mark_init: -1,
        mark_ticks_step: -1,
        mark_ticks_offset: 0,
        mark_ticks_color: "#EEEEEE"
    },
    temp_bar: {
        offset: 0,
        mark_init: 0.6, // Length ratio between base and bar
        mark_ticks_step: -1,
        mark_ticks_offset: 0,
        mark_ticks_color: "#EEEEEE"
    },
    speed_bar: {
        offset: 0,
        mark_init: 0.6,
        mark_ticks_step: 1,
        mark_ticks_offset: 0.5,
        mark_ticks_color: "#EEEEEE"
    },
    dial_big: {
        box_size: 300,
        bar_margin: 0.03,
        bar_color: "#44AB43",
        bar_width: 5,
        barMark_width: 4,
        barMark_color: '#000000',
        base_margin: 0.18,
        base_color: "#DDDDDD",
        base_shadowBlurpx: 3,
        base_shadowXpx: 1,
        base_shadowYpx: 2,
        base_shadowColor: "#000000",
        titleText_color: "#000000",
        titleText_font: "21px Verdana",
        subtitleText_color: "#AAAAAA",
        subtitleText_font: "11px Verdana",
        subtitleText_offset: 0.11,
        topText_color: "#888888",
        topText_font: "20px Verdana",
        topText_offset: 0.45,
        symbol_offset: 0.6,
        // For text symbols
        symbol_font: "18px Verdana",
        symbol_color: "#888888",
        // For image symbols
        symbol_size: 18
    },
    dial_small: {
        box_size: 200,
        bar_margin: 0.02,
        bar_color: "#44AB43",
        bar_width: 3,
        barMark_width: 2,
        barMark_color: '#000000',
        base_margin: 0.15,
        base_color: "#DDDDDD",
        base_shadowBlurpx: 3,
        base_shadowXpx: 1,
        base_shadowYpx: 2,
        base_shadowColor: "#000000",
        titleText_color: "#000000",
        titleText_font: "17px Verdana",
        subtitleText_color: "#AAAAAA",
        subtitleText_font: "10px Verdana",
        subtitleText_offset: 0.13,
        topText_color: "#888888",
        topText_font: "15px Verdana",
        topText_offset: 0.45,
        symbol_offset: 0.6,
        // For text symbols
        symbol_font: "15px Verdana",
        symbol_color: "#888888",
        // For image symbols
        symbol_size: 15
    },
    generic: {
        text_color: "#000000",
        text_font: "17px Verdana",
    },
    generic_small: {
        text_color: "#333333",
        text_font: "12px Verdana",
    }
};

function changeScreen(screen) {
    gachaneitor_status.screen = screen;
    gachaneitor_status.invalidated = true;
}

function redraw(conf) {
    g.drawImage(g_config.base_img, 0, 0, canvas.width, canvas.height);
    if(g_config.cover_shown) {
        g.drawImage(g_config.cover_img, 0, 0, canvas.width, canvas.height);
    }
    gachaneitor_status.invalidated = true;
}

function clearScreen(conf) {
    g.fillStyle = conf.screen_background_color;
    g.fillRect(conf.screen_x, conf.screen_y, conf.screen_width, conf.screen_height);
}

function clearRegion(x, y, size, color) {
    g.fillStyle = color;
    g.fillRect(x - size/2, y - size/2, size, size);
}

function drawDialBase(x, y, dial_conf) {
    g.shadowBlur = dial_conf.base_shadowBlurpx;
    g.shadowOffsetX = dial_conf.base_shadowXpx;
    g.shadowOffsetY = dial_conf.base_shadowYpx;
    g.shadowColor = dial_conf.base_shadowColor;

    g.fillStyle = dial_conf.base_color;
    g.beginPath();
    g.arc(x, y, ((1-dial_conf.base_margin)*dial_conf.box_size)/2, 0, 2 * Math.PI);
    g.fill();

    g.shadowBlur = 0;
    g.shadowOffsetX = 0;
    g.shadowOffsetY = 0;
}

function drawDialProgressBar(x, y, value, min_value, max_value, bar_conf, dial_conf) {

    var step_angle = 1.9 * (1 / (max_value - min_value)) * Math.PI;
    var init_angle = (-0.5 + bar_conf.offset) * Math.PI;
    var current_angle = init_angle + (value - min_value) * step_angle;
    var max_angle = init_angle + 1.9 * Math.PI;

    // Draw bar background
    g.strokeStyle = "#CCCCCC";//dial_conf.bar_backgroundColor;
    g.lineWidth = dial_conf.bar_width;
    g.beginPath();
    g.arc(x, y,
        ((1-dial_conf.bar_margin)*dial_conf.box_size)/2,
        init_angle,
        max_angle);
    g.stroke();

    // Draw bar
    g.strokeStyle = dial_conf.bar_color;
    g.lineWidth = dial_conf.bar_width;
    g.beginPath();
    g.arc(x, y,
        ((1-dial_conf.bar_margin)*dial_conf.box_size)/2,
        init_angle, 
        current_angle);
    g.stroke();

    // Draw bar ticks
    if(bar_conf.mark_ticks_step > 0) {
        var tick_angle = init_angle + bar_conf.mark_ticks_offset * step_angle;

        g.save();
        g.strokeStyle = bar_conf.mark_ticks_color;
        
        g.translate(x, y);
        g.rotate(tick_angle);

        while(tick_angle < max_angle) {
            g.lineWidth = Math.abs(tick_angle - current_angle) < 0.01 ? 2*dial_conf.barMark_width : dial_conf.barMark_width;

            g.beginPath();
            g.moveTo(((1-0.5*dial_conf.base_margin) * dial_conf.box_size)/2, 0);
            g.lineTo(dial_conf.box_size/2, 0);
            g.stroke();

            tick_angle += bar_conf.mark_ticks_step * step_angle;
            g.rotate(bar_conf.mark_ticks_step * step_angle);
        }
        g.restore();
    }

    // Draw bar init mark
    if(bar_conf.mark_init > 0) {
        g.save();
        g.strokeStyle = dial_conf.bar_color;
        g.lineWidth = dial_conf.barMark_width;
        g.beginPath();
        g.translate(x, y);
        g.rotate(init_angle);
        g.moveTo(((1-bar_conf.mark_init*dial_conf.base_margin) * dial_conf.box_size)/2, 0);
        g.lineTo(dial_conf.box_size/2, 0);
        g.stroke();
        g.restore();
    }

    // Draw bar mark
    g.save();
    g.strokeStyle = dial_conf.barMark_color;
    g.lineWidth = dial_conf.barMark_width;
    g.beginPath();
    g.translate(x, y);
    g.rotate(current_angle);
    g.moveTo(((1-0.75*dial_conf.base_margin) * dial_conf.box_size)/2, 0);
    g.lineTo(dial_conf.box_size/2, 0);
    g.stroke();
    g.restore();
}

function drawDialTitle(x, y, text, dial_conf) {
    g.fillStyle = dial_conf.titleText_color;
    g.font = dial_conf.titleText_font;
    g.textBaseline = 'middle';
    g.textAlign = "center";
    g.fillText(text, x, y);
}

function drawDialSubtitle(x, y, text, dial_conf) {
    g.fillStyle = dial_conf.subtitleText_color;
    g.font = dial_conf.subtitleText_font;
    g.textBaseline = 'middle';
    g.textAlign = "center";
    g.fillText(text, x, y + dial_conf.subtitleText_offset * dial_conf.box_size);
}

function drawDialTopText(x, y, text, dial_conf) {
    g.fillStyle = dial_conf.topText_color;
    g.font = dial_conf.topText_font;
    g.textBaseline = 'middle';
    g.textAlign = "center";
    g.fillText(text, x, y - dial_conf.topText_offset * dial_conf.box_size/2);
}

function drawDialSymbol(x, y, image, text, dial_conf) {
    if(image != null) {
        g.drawImage(image,
            x - (dial_conf.symbol_size/2),
            y + (dial_conf.symbol_offset*dial_conf.box_size)/2 - (dial_conf.symbol_size/2),
            dial_conf.symbol_size,
            dial_conf.symbol_size);
    } else {
        g.fillStyle = dial_conf.symbol_color;
        g.font = dial_conf.symbol_font;
        g.textBaseline = 'middle';
        g.textAlign = "center";
        g.fillText(text, x, y + (dial_conf.symbol_offset*dial_conf.box_size)/2);
    }
}

function drawTime(time, target_time, x, y, conf, is_big) {
    if(is_big)
        dial_conf = conf.dial_big;
    else
        dial_conf = conf.dial_small;

    // Clear previous
    clearRegion(x, y, dial_conf.box_size, conf.screen_background_color);
    
    // Draw circle base
    drawDialBase(x, y, dial_conf);

    // Draw bar
    drawDialProgressBar(x, y,
        time[0]*60 + time[1],
        0, target_time[0]*60 + target_time[1],
        conf.time_bar,
        dial_conf);

    // Draw text value
    drawDialTitle(x, y,
        (time[0] < 10 ? "0" + time[0] : time[0]) + ":" + (time[1] < 10 ? "0" + time[1] : time[1]),
        dial_conf);

    // Draw min_sec text
    drawDialSubtitle(x, y,
        "min   sec",
        dial_conf);

    // Draw symbol
    drawDialSymbol(x, y, conf.time_symbol_img, "", dial_conf);
}

// temp = [temp_min:temp_max] => show temperature value
// temp = [0:temp_min] => "---"
// temp < 0 => Show "varoma" and the positive value on top
//      ej: -50 will show "varoma" in the middle and "50" on top
function drawTemp(temp, x, y, conf, is_big) {

    if(is_big)
        dial_conf = conf.dial_big;
    else
        dial_conf = conf.dial_small;

    // Clear previous
    clearRegion(x, y, dial_conf.box_size, conf.screen_background_color);

    // Draw circle base
    drawDialBase(x, y, dial_conf);

    // Draw bar
    drawDialProgressBar(x, y,
        Math.abs(temp) > conf.temp_min ? Math.abs(temp) : conf.temp_min,
        conf.temp_min, conf.temp_max,
        conf.temp_bar, dial_conf);

    // Draw temperature value
    if(Math.abs(temp) < conf.temp_min) {
        drawDialTitle(x, y,
            "---",
            dial_conf);
    } else if(temp >= conf.temp_min) {
        drawDialTitle(x, y,
            temp,
            dial_conf); 
    } else {
        drawDialTitle(x, y,
            "VAROMA",
            dial_conf);
        drawDialTopText(x, y,
            -1 * temp,
            dial_conf);
    }  

    // Draw symbol
    drawDialSymbol(x, y, null, "°C ", dial_conf);
}

function speedToText(speed) {
    if(speed >= 0)
        return speed.toFixed(1);
    else if(speed == -1)
        return "CUCHARA";
    else if(speed == -2)
        return "ESPIGA";
    else if(speed == -3)
        return "TURBO";
    else
        return "0.0";
}

function drawSpeed(speed, x, y, conf, is_big) {
    if(is_big)
        dial_conf = conf.dial_big;
    else
        dial_conf = conf.dial_small;

    // Clear previous
    clearRegion(x, y, dial_conf.box_size, conf.screen_background_color);

    // Draw circle base
    drawDialBase(x, y, dial_conf);

    // Draw bar
    drawDialProgressBar(x, y,
        speed+0.5,
        conf.speed_min, conf.speed_max+0.5,
        conf.speed_bar, dial_conf);

    // Draw text value
    drawDialTitle(x, y,
        speedToText(speed),
        dial_conf);

    // Draw symbol
    drawDialSymbol(x, y, conf.speed_symbol_img, "", dial_conf);
}

function drawImage(image, x, y, w, h) {
    g.drawImage(image, x, y, w, h);
}

function drawText(text, x, y, w, h, conf) {    
    g.fillStyle = conf.text_color;
    g.font = conf.text_font;
    g.textBaseline = 'middle';
    g.textAlign = "left";
    var y_initial = y;
    y += 0.6 * parseInt(g.font.match(/\d+/), 10);

    var words = text.split(' ');
    var line = '';
    words.forEach(word => {
        if(y > y_initial + h) return;
        if(g.measureText(line + word).width > w) {
            g.fillText(line, x, y);
            y += 1.5 * parseInt(g.font.match(/\d+/), 10);

            if(g.measureText(word).width <= w)
                line = word + ' ';
            else
                line = word.substring(0, line.length - 4) + '... ';
        } else
            line += word + ' ';
    });
    g.fillText(line, x, y);
}

function onDraw() {
    if(gachaneitor_status.invalidated)
        clearScreen(g_config);

    switch(gachaneitor_status.screen) {
        case SCREEN.PROGRAM:
            drawTime(gachaneitor_status.time, gachaneitor_status.time_target,
                g_config.screen_x + 0.5 * g_config.screen_width/3,
                g_config.screen_y + g_config.screen_height/2,
                g_config,
                gachaneitor_status.screen_properties.program.selected == 'time');
            drawTemp(gachaneitor_status.temp,
                g_config.screen_x + 1.5 * g_config.screen_width/3,
                g_config.screen_y + g_config.screen_height/2,
                g_config,
                gachaneitor_status.screen_properties.program.selected == 'temp');
            drawSpeed(gachaneitor_status.speed,
                g_config.screen_x + 2.5 * g_config.screen_width/3,
                g_config.screen_y + g_config.screen_height/2,
                g_config,
                gachaneitor_status.screen_properties.program.selected == 'speed');
            break;

        case SCREEN.ADD:
            if(!gachaneitor_status.invalidated) break;
            drawText(
                'Añada',
                g_config.screen_x + 1.05 * g_config.screen_height,
                g_config.screen_y + 0.05 * g_config.screen_height,
                g_config.screen_width - 1.1 * g_config.screen_height,
                0.17 * g_config.screen_height,
                g_config.generic_small);
            drawText(
                `${gachaneitor_status.screen_properties.add.ingredient_name}`,
                g_config.screen_x + 1.05 * g_config.screen_height,
                g_config.screen_y + 0.17 * g_config.screen_height,
                g_config.screen_width - 1.1 * g_config.screen_height,
                0.78 * g_config.screen_height,
                g_config.generic);
            drawImage(g_config.add_img,
                g_config.screen_x + 0.05 * g_config.screen_height,
                g_config.screen_y + 0.05 * g_config.screen_height,
                0.9 * g_config.screen_height,
                g_config.screen_height - 0.1 * g_config.screen_height);
            break;
        case SCREEN.TAKE:
            if(!gachaneitor_status.invalidated) break;
            
            drawText(
                'Retire',
                g_config.screen_x + 1.05 * g_config.screen_height,
                g_config.screen_y + 0.05 * g_config.screen_height,
                g_config.screen_width - 1.1 * g_config.screen_height,
                0.17 * g_config.screen_height - 0.1 * g_config.screen_height,
                g_config.generic_small);
            drawText(
                `${gachaneitor_status.screen_properties.take.content}`,
                g_config.screen_x + 1.05 * g_config.screen_height,
                g_config.screen_y + 0.17 * g_config.screen_height,
                g_config.screen_width - 1.1 * g_config.screen_height,
                0.78 * g_config.screen_height,
                g_config.generic);
            drawImage(g_config.take_img,
                g_config.screen_x + 0.05 * g_config.screen_height,
                g_config.screen_y + 0.05 * g_config.screen_height,
                0.9 * g_config.screen_height,
                g_config.screen_height - 0.1 * g_config.screen_height);
            break;
        case SCREEN.USER_ACTION:
            if(!gachaneitor_status.invalidated) break;

            drawText(
                gachaneitor_status.screen_properties.useraction.action,
                g_config.screen_x + 1.05 * g_config.screen_height,
                g_config.screen_y + 0.1 * g_config.screen_height,
                g_config.screen_width - 1.1 * g_config.screen_height,
                0.75 * g_config.screen_height,
                g_config.generic);
            drawImage(g_config.useraction_img,
                g_config.screen_x + 0.05 * g_config.screen_height,
                g_config.screen_y + 0.05 * g_config.screen_height,
                0.9 * g_config.screen_height,
                g_config.screen_height - 0.1 * g_config.screen_height);
            break;
    }
    gachaneitor_status.invalidated = false;
}
