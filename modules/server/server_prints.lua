local Console = {
	resourceName = 'hbd_carrybike',
	resourceVersion = '1.0.0'
}

CreateThread(function()
	print('[' .. Console.resourceName .. '] v' .. Console.resourceVersion .. ' started!')
end)