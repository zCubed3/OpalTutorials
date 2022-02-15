//
// Example PSX shader that explains concepts of replicating PS1 style graphics
//

//
// Since this is a Misc category shader, expect documentation on only necessary parts!
//

Shader "Opal/Tutorials/PSX"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        
        // Fake screen res to snap vertices too
        _FakeRes ("Fake Resolution", Vector) = (320, 240, 0, 0)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;

                // This is a new feature keyword for some
                // You can disable perspective correction in HLSL with "noperspective"
                // This is better explained below in the vert function
                noperspective float2 uv : TEXCOORD0;
            };

            sampler2D _MainTex;
            half2 _FakeRes;

            v2f vert (appdata v)
            {
                v2f o;

                //
                // Crucial parts to replicating PS1 style graphics
                //
                // 1) Disabling perspective correction on textures
                // 2) Snapping vertices to pixels on the screen
                // 3) Unlit, or per vertex lighting
                //
                // Effect 1 is super easy, we can disable perspective correction using "noperspective"
                // This is what caused wobbly textures on objects inside of PS1 games
                // While the effect is a lot stronger when there are less vertices, many PS1 games hid this very well
                // They would use subdivided geometry in places where textures would have a very apparent shift
                // To explain what noperspective does, on modern GPU hardware, interpolated values are corrected along the depth of the screen
                // The PS1 cut corners and didn't correct for this depth, which led to precision loss along the edges of a given polygon
                //
                // Effect 2 is super easy as well but has no special keyword to cheat!
                // On the PS1, they had limited floating point precision in the frame buffer, so they'd just snap vertices to the nearest pixel
                // We can achieve this via truncating precision using rounding!
                //
                // For Effect 3 we've opted for a simple Unlit approach here, per vertex lighting is a more complex topic that'd bloat this example!

                // Effect 2 process
                // Calculate normal clip space vertex
                o.vertex = UnityObjectToClipPos(v.vertex);

                // Then create a duplicate we truncate the precision of...
                float4 snapVertex = o.vertex;

                // Dividing by W removes prespective from the clip space position
                // This is useful for flattening everything for snapping
                snapVertex.xyz /= snapVertex.w;

                // Then we multiply by our fake res
                snapVertex.xy *= _FakeRes.xy;

                // Then we floor our value, effectively rounding it within the precision we've given it
                snapVertex.xy = floor(snapVertex.xy);

                // Then we divide this by our fake res to retrieve the snapped clip position
                snapVertex.xy /= _FakeRes.xy;

                // We then bring back the perspective by multiplying by W
                snapVertex.xyz *= snapVertex.w;

                // And finally our vertex has been snapped
                o.vertex = snapVertex;

                // UVs work out of the box here
                o.uv = v.uv;
                
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return tex2D(_MainTex, i.uv);
            }
            ENDCG
        }
    }
}
