target    = 100
runtime   = os.clock() + 30
base      = 1e-5* balance
minbet    = 1e-4
chance    = 49.5
nextbet   = minbet
streakcnt = 0
rec       = {0}
rec10     = {0}
rec10cnt  = 0
rec25     = {0}
rec25cnt  = 0
rec33     = {0}
rec33cnt  = 0 
rec50     = {0}
rec50cnt  = 0
rec66     = {0}
rec66cnt  = 0
a         = 0
initcnt   = 0
mult      = 0
maxstreak = 1
profitc   = 0

cw = 0
cl = 0
--10x function
function add(t)
    local sum = 0
    for i, v in ipairs(t) do
        sum = sum + v
    end
    return sum
end
--5x function

function dobet()
    profitc = profit + currentprofit
    if profitc > 0 then
        if os.clock() > runtime then
            --print("+ " .. fix8(profit) .. "\t(" .. fix2(profit / (balance - profit) * 100) .. "%)")
            stop()
            start()
        end
        profitc = 0
    end
    chance  = 33
    nextbet = base
    bethigh = true 
    mult    = 1.55

    initcnt = initcnt + 1

    --1.5x routine
    if lastBet.roll > 66 then
        table.insert(rec66, 1, "1")
    else
        table.insert(rec66, 1, "0")
    end
    rec66cnt = 33 / ((add(rec66) / #rec66) * 100)
    if (rec66cnt) >= maxstreak then
        chance  = 66
        mult    = 3.5
        bethigh = false 
    end
    table.remove(rec66, 31)

    --2x routine
    if lastBet.roll > 50 then
        table.insert(rec50, 1, "1")
    else
        table.insert(rec50, 1, "0")
    end
    rec50cnt = 50 / ((add(rec50) / #rec50) * 100)
    if (rec50cnt) >= maxstreak then
        chance  = 50
        mult    = 2.5
        bethigh = false 
    end
    table.remove(rec50, 51)

    --3x routine
    if lastBet.roll > 33 then
        table.insert(rec33, 1, "1")
    else
        table.insert(rec33, 1, "0")
    end
    rec33cnt = 66 / ((add(rec33) / #rec33) * 100)
    if (rec33cnt) >= maxstreak then
        chance  = 33
        mult    = 2 
        bethigh = false
    end
    table.remove(rec33, 67)

    --5x routine
    if lastBet.roll > 25 then
        table.insert(rec25, 1, "1")
    else
        table.insert(rec25, 1, "0")
    end
    rec25cnt = 75 / ((add(rec25) / #rec25) * 100)
    if (rec25cnt) >= maxstreak then
        chance  = 25
        mult    = 1.5
        bethigh = false 
    end
    table.remove(rec25, 76)

    --10x routine
    if lastBet.roll > 10 then
        table.insert(rec10, 1, "1")
    else
        table.insert(rec10, 1, "0")
    end
    rec10cnt = 90 / ((add(rec10) / #rec10) * 100)
    if rec10cnt >= maxstreak then
        chance  = 10
        mult    = 1.2
        bethigh = false 
    end
    table.remove(rec10, 91)

    --bet armount routine
    if win then
        a       = 0
        nextbet = base 
    else
        a       = a - currentprofit
        nextbet = math.abs(profit)/((99/chance)-1)*0.55
        if nextbet < minbet then nextbet= minbet end--previousbet * mult
    end

    if nextbet < base then
        nextbet = base
    end

    --output
    if initcnt > 90 then
        print("")
        --print("[ 1.5x \t: " .. fix2(rec66cnt) .. "% ]")
        --print("[ 2.0x \t: " .. fix2(rec50cnt) .. "% ]")
        --print("[ 3.0x \t: " .. fix2(rec33cnt) .. "% ]")
        --print("[ 5.0x \t: " .. fix2(rec25cnt) .. "% ]")
        --print("[ 10.0x\t: " .. fix2(rec10cnt) .. "% ]")
        --fn_simplestats()
    end

    --init and fixes
    if initcnt < 90 then
        print("[ Populating array " .. math.floor(initcnt / 90 * 100) .. "% ]")
        if win then
             cw = cw+1
             cl = 0
               chance  = 99.9
               nextbet = balance/250
             if  (cw%2==0) then
                 nextbet = balance/25000
                 chance  = 90
             end
         else
             cw      = 0
             cl      = cl+1
             chance  = 90
             nextbet = previousbet*10--balance/490
           
         end
         end
        
    
        
        
    end
    nextbet = math.floor(nextbet * 1e8) * 1e-8

    if balance > target then
        stop()
    end
end

status = ""
maxdrop = 30

if (profit == 0) then
    stopifwin         = false 
    simplestats_balhi = balance
    simplestats_balst = balance
    simplestats_profit, simplestats_maxdrop, simplestats_profitc, simplestats_wager = 0, 0, 0, 0
end

function fn_simplestats()
    simplestats_profit  = simplestats_profit + currentprofit 
    simplestats_wager   = simplestats_wager + previousbet
    simplestats_profitc = simplestats_profitc + currentprofit
    if (simplestats_profitc >= 0) then
        if stopifwin then
            stop()
        end
        simplestats_profitc = 0
        simplestats_balhi   = balance 
    end
    simplestats_drop = simplestats_balhi - balance
    if (simplestats_drop > simplestats_maxdrop) then
        simplestats_maxdrop = simplestats_drop
    end
    if simplestats_drop / simplestats_balhi * 100 > maxdrop and maxdrop > 0 then
        stopifwin = true
    end
    print("░▒▓- Status   \t[ " .. status .. " ]")
    print("░▒▓- Profit   \t[ " ..fix8(simplestats_profit) .. "\t" .. fix2(simplestats_profit / (balance - simplestats_profit) * 100) .. "% ]")
    print("░▒▓- Dropdown \t[ " ..fix8(simplestats_maxdrop) .. "\t" .. fix2(simplestats_maxdrop / simplestats_balhi * 100) .. "% ]")
    print("░▒▓- Wager    \t[ " ..fix8(simplestats_wager) .. "\t" .. fix2(simplestats_wager / simplestats_balst * 100) .. "% ]")
end

function fix8(text)
    return string.format("%.8f", text)
end

function fix2(text)
    return string.format("%.2f", text)
end
