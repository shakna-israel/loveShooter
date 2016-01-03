debug = true

player = {x = (love.graphics.getWidth()/2) - 20, y = ((love.graphics.getHeight() - 100) + 10), speed = 200, img = nil, isAlive = true, score = 0}

canShoot = True
canShootTimerMax = 0.2
canShootTimer = canShootTimerMax
bulletImg = nil
bullets = {}

createEnemyTimerMax = 2
createEnemyTimer = createEnemyTimerMax
enemyImg = nil
enemies = {}

explosions = {}
explosionDieTimerMax = 10

function CheckCollision(x1, y1, w1, h1, x2, y2, w2, h2)
    return x1 < x2+w2 and
           x2 < x1+w1 and
           y1 < y2+h2 and
           y2 < y1+h1
end

function love.load(arg)
    player.img = love.graphics.newImage('assets/plane.png')
    bulletImg = love.graphics.newImage('assets/bullet.png')
    enemyImg = love.graphics.newImage('assets/enemy.png')
    rocketImg = love.graphics.newImage('assets/rocket.png')
    bulletBlue = love.graphics.newImage('assets/bullet_blue.png')
    explosionImg = love.graphics.newImage('assets/explosion.png')
end

function love.update(dt)
    for i, enemy in ipairs(enemies) do
        for j, bullet in ipairs(bullets) do
            if CheckCollision(enemy.x, enemy.y, enemy.img:getWidth(), enemy.img:getHeight(), bullet.x, bullet.y, bullet.img:getWidth(), bullet.img:getHeight()) then
                newExplosion = { img = explosionImg, x = enemy.x + (enemy.img:getWidth()/2), y = enemy.y + (enemy.img:getWidth()/2), timer = explosionDieTimerMax}
                table.insert(explosions, newExplosion)
                table.remove(bullets, j)
                table.remove(enemies, i)
                player.score = player.score + 1
            end
        end
        if CheckCollision(enemy.x, enemy.y, enemy.img:getWidth(), enemy.img:getHeight(), player.x, player.y, player.img:getWidth(), player.img:getHeight()) and player.isAlive then
            table.remove(enemies, i)
            player.isAlive = false
        end
    end
    if player.score > 30 then
        canShootTimer = canShootTimer - ((1 + (player.score/30)) * dt)
    else
        canShootTimer = canShootTimer - (1 * dt)
    end
    if canShootTimer < 0 then
        canShoot = true
    end
    if love.keyboard.isDown('escape') then
        love.event.push('quit')
    end
    if love.keyboard.isDown('left','a') and player.isAlive then
        if player.x > 0 then
            player.x = player.x - ((player.speed + player.score)*dt)
        end
    elseif love.keyboard.isDown('right','d') and player.isAlive then
        if player.x < (love.graphics.getWidth() - player.img:getWidth()) then
            player.x = player.x + ((player.speed + player.score)*dt)
        end
    end
    if love.keyboard.isDown('w','up') and player.isAlive then
        if player.y > (love.graphics.getHeight()/2) then
            player.y = player.y - ((player.speed + player.score)*dt)
        end
    end
    if love.keyboard.isDown('down','s') and player.isAlive then
        if player.y < (love.graphics.getHeight() - player.img:getHeight()) then
            player.y = player.y + ((player.speed + player.score)*dt)
        end
    end
    if love.keyboard.isDown(' ', 'rctrl', 'lctrl', 'ctrl') and canShoot and player.isAlive then
        if player.score < 30 then
            newBullet = {x = player.x + (player.img:getWidth()/2), y = player.y, img = bulletImg, speed = 250 }
        elseif player.score > 100 then
            newBullet = {x = player.x + (player.img:getWidth()/2), y = player.y, img = bulletBlue, speed = 700}
        else
            newBullet = {x = player.x + (player.img:getWidth()/2), y = player.y, img = rocketImg, speed = 550}
        end
        table.insert(bullets, newBullet)
        canShoot = false
        canShootTimer = canShootTimerMax
    end
    for i, bullet in ipairs(bullets) do
        bullet.y = bullet.y - (bullet.speed * dt)
        if bullet.y < 0 then
            table.remove(bullets, i)
        end
    end
    if player.score > 30 and player.isAlive then
        createEnemyTimer = createEnemyTimer - ((1 + (player.score/30)) * dt)
    else
        createEnemyTimer = createEnemyTimer - (1 * dt)
    end
    if createEnemyTimer < 1 then
        createEnemyTimer = createEnemyTimerMax
        randomNumber = math.random(enemyImg:getWidth(), love.graphics.getWidth() - enemyImg:getWidth())
        newEnemy = { x = randomNumber, y = -50, img = enemyImg }
        table.insert(enemies, newEnemy)
    end
    for i, enemy in ipairs(enemies) do
        if enemy.x > (love.graphics.getWidth() - enemy.img:getWidth()) then
            enemy.x = enemy.x + (1 * dt)
        elseif enemy.x < (love.graphics.getWidth() + enemy.img:getWidth()) then
            enemy.x = enemy.x - (1 * dt)
        end
    end
    for i, enemy in ipairs(enemies) do
        enemy.y = enemy.y + (200 * dt)
        if enemy.y > love.graphics.getHeight() then
            table.remove(enemies, i)
        end
    end
    if not player.isAlive and love.keyboard.isDown('r') then
        bullets = {}
        enemies = {}
        canShootTimer = canShootTimerMax
        createEnemyTimer = createEnemyTimerMax
        player.x = (love.graphics.getWidth()/2) - (player.img:getWidth()/2)
        player.y = ((love.graphics.getHeight() - 100) + 10)
        player.score = 0
        player.isAlive = true
    end
    for i, explosion in ipairs(explosions) do
        if explosion.timer < 0 then
            table.remove(explosions, i)
        end
    end
end

function love.draw(dt)
    love.graphics.setColor(255, 255, 255)
    love.graphics.print("Score: " .. tostring(player.score), (love.graphics.getWidth()/2) - 10, 10)
    if player.isAlive then
        love.graphics.draw(player.img, player.x, player.y)
    else
        love.graphics.print("Press 'R' to restart", love.graphics:getWidth()/2-50, love.graphics:getHeight()/2-10)
    end
    for i, bullet in ipairs(bullets) do
        love.graphics.draw(bullet.img, bullet.x, bullet.y)
    end
    for i, enemy in ipairs(enemies) do
        love.graphics.draw(enemy.img, enemy.x, enemy.y)
    end
    for i, explosion in ipairs(explosions) do
        love.graphics.draw(explosion.img, explosion.x, explosion.y)
        explosion.timer = explosion.timer - 1
    end
end