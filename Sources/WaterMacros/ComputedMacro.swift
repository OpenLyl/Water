import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct ComputedMacro {
    
}

extension ComputedMacro: PeerMacro {
    public static func expansion<
        Context: MacroExpansionContext,
        Declaration: DeclSyntaxProtocol
    >(
        of node: SwiftSyntax.AttributeSyntax,
        providingPeersOf declaration: Declaration,
        in context: Context
    ) throws -> [DeclSyntax] {
//        var s = VariableDeclSyntax()
//        s.bindingKeyword = 
        let vds = try! VariableDeclSyntax("var _count: Int") {
            StmtSyntax(" get { return count.wrappedValue } ")
        }
        let storage = DeclSyntax(vds)
        return [
            storage
        ]
        
        //        let propertySyntax: DeclSyntax =
        //        """
        //        var _count = 10
        //        """
        //        let vs = VariableDeclSyntax {
        //            $0.lv
        //        }
        //
        //        return [
        //            propertySyntax
        //        ]
    }
}

//extension ComputedMacro: AccessorMacro {
//    public static func expansion(of node: AttributeSyntax, providingAccessorsOf declaration: some DeclSyntaxProtocol, in context: some MacroExpansionContext) throws -> [AccessorDeclSyntax] {
//        let getAccessor: AccessorDeclSyntax =
//          """
//          get { return count.wrappedValue }
//          """
//        let setAccessor: AccessorDeclSyntax =
//          """
//          set { count.wrappedValue = newValue }
//          """
//        return [
//            getAccessor,
//            setAccessor,
//        ]
//    }
//}

@main
struct PropertyWrapperMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        ComputedMacro.self,
    ]
}
