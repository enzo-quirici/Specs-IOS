import Foundation
import UIKit
import Darwin

public struct SystemUtils {
    
    // MARK: - CPU overall usage (rough percent)
    public static func cpuUsagePercent() -> Double {
        var count: mach_msg_type_number_t = 0
        var cpuInfo: processor_info_array_t? = nil
        var numCPU: natural_t = 0
        
        let kr = host_processor_info(mach_host_self(),
                                     PROCESSOR_CPU_LOAD_INFO,
                                     &numCPU,
                                     &cpuInfo,
                                     &count)
        if kr != KERN_SUCCESS || cpuInfo == nil {
            return -1.0
        }
        
        let cpuPtr = cpuInfo!
        var totalTicks: UInt = 0
        var totalIdle: UInt = 0
        
        for i in 0..<Int(numCPU) {
            let base = Int(CPU_STATE_MAX) * i
            let user = UInt(cpuPtr[base + Int(CPU_STATE_USER)])
            let nice = UInt(cpuPtr[base + Int(CPU_STATE_NICE)])
            let system = UInt(cpuPtr[base + Int(CPU_STATE_SYSTEM)])
            let idle = UInt(cpuPtr[base + Int(CPU_STATE_IDLE)])
            
            totalTicks += user + nice + system + idle
            totalIdle += idle
        }
        
        // free the allocated array
        let size = vm_size_t(count) * vm_size_t(MemoryLayout<integer_t>.size)
        let addr = vm_address_t(UInt(bitPattern: cpuPtr))
        vm_deallocate(mach_task_self_, addr, size)
        
        if totalTicks == 0 { return 0.0 }
        let busy = Double(totalTicks - totalIdle)
        return (busy / Double(totalTicks)) * 100.0
    }
    
    // MARK: - CPU delta sample
    public struct CPUInfoSample {
        var total: UInt
        var idle: UInt
    }
    
    public static func sampleCPU() -> CPUInfoSample? {
        var count: mach_msg_type_number_t = 0
        var cpuInfo: processor_info_array_t? = nil
        var numCPU: natural_t = 0
        
        let kr = host_processor_info(mach_host_self(),
                                     PROCESSOR_CPU_LOAD_INFO,
                                     &numCPU,
                                     &cpuInfo,
                                     &count)
        if kr != KERN_SUCCESS || cpuInfo == nil {
            return nil
        }
        
        let cpuPtr = cpuInfo!
        var totalTicks: UInt = 0
        var totalIdle: UInt = 0
        
        for i in 0..<Int(numCPU) {
            let base = Int(CPU_STATE_MAX) * i
            let user = UInt(cpuPtr[base + Int(CPU_STATE_USER)])
            let nice = UInt(cpuPtr[base + Int(CPU_STATE_NICE)])
            let system = UInt(cpuPtr[base + Int(CPU_STATE_SYSTEM)])
            let idle = UInt(cpuPtr[base + Int(CPU_STATE_IDLE)])
            
            totalTicks += user + nice + system + idle
            totalIdle += idle
        }
        
        let size = vm_size_t(count) * vm_size_t(MemoryLayout<integer_t>.size)
        let addr = vm_address_t(UInt(bitPattern: cpuPtr))
        vm_deallocate(mach_task_self_, addr, size)
        
        return CPUInfoSample(total: totalTicks, idle: totalIdle)
    }
    
    public static func cpuUsageBetween(_ oldSample: CPUInfoSample, _ newSample: CPUInfoSample) -> Double {
        let totalDelta = Double(newSample.total - oldSample.total)
        let idleDelta = Double(newSample.idle - oldSample.idle)
        if totalDelta <= 0 { return 0.0 }
        let busy = totalDelta - idleDelta
        return (busy / totalDelta) * 100.0
    }
    
    // MARK: - Memory info
    public static func memoryInfo() -> (used: UInt64, free: UInt64, total: UInt64)? {
        var size = mach_msg_type_number_t(MemoryLayout<vm_statistics_data_t>.size / MemoryLayout<integer_t>.size)
        var vmStat = vm_statistics_data_t()
        
        let result = withUnsafeMutablePointer(to: &vmStat) { ptr -> kern_return_t in
            ptr.withMemoryRebound(to: integer_t.self, capacity: Int(size)) {
                host_statistics(mach_host_self(), HOST_VM_INFO, $0, &size)
            }
        }
        
        if result != KERN_SUCCESS { return nil }
        
        let pageSize = UInt64(vm_kernel_page_size)
        let free = UInt64(vmStat.free_count) * pageSize
        let active = UInt64(vmStat.active_count) * pageSize
        let inactive = UInt64(vmStat.inactive_count) * pageSize
        let wired = UInt64(vmStat.wire_count) * pageSize
        
        let used = active + inactive + wired
        let total = used + free
        return (used: used, free: free, total: total)
    }
    
    // MARK: - Battery info (iOS 9 compatible)
    public static func batteryStateAndLevel() -> (state: UIDeviceBatteryState, level: Float) {
        let device = UIDevice.current
        device.isBatteryMonitoringEnabled = true
        return (state: device.batteryState, level: device.batteryLevel)
    }
}
